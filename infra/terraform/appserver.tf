resource "aws_instance" "appserver" {
  for_each                    = toset(local.availability_zones)

  availability_zone           = each.value
  subnet_id                   = aws_subnet.private[each.value].id
  associate_public_ip_address = false
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  user_data                   = data.cloudinit_config.user_data.rendered
  key_name                    = var.appserver_private_ssh_key_name
  vpc_security_group_ids      = [ aws_security_group.appserver.id ]
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.this.name

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 10
  }

tags = {
    Name        = join("_", [var.project_name, "_appserver"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "appserver" {
  name        = join("_", [var.project_name, "_appserver_security_group"])
  description = "security group for application server"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name        = join("_", [var.project_name, "_appserver_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }

  # Dependency is used to ensure that VPC has an Internet gateway
  depends_on  = [ aws_internet_gateway.this ]
}

resource "aws_iam_instance_profile" "this" {
  name = join("_", [var.project_name, "_ec2_profile"])
  role = aws_iam_role.appserver_iam_role.name
}

resource "aws_iam_role" "appserver_iam_role" {
  name        = join("", [title(var.project_name), "AppserverRole"])
  description = "The role for EC2 instances for appserver"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    sid           = "1"
    effect        = "Allow"
    actions       = [ "sts:AssumeRole" ]
    principals {
      type        = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.appserver_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "GetDeploymentAndGetSSMParameter" {
  role       = aws_iam_role.appserver_iam_role.name
  policy_arn = aws_iam_policy.read_access_to_parameters_and_deployments.arn
}

resource "aws_iam_policy" "read_access_to_parameters_and_deployments" {
  name        = "test-policy"
  description = "Allow to get deployment information to retrieve a commitId hash"
  policy      = data.aws_iam_policy_document.read_access_to_parameters_and_deployments.json
}

data "aws_iam_policy_document" "read_access_to_parameters_and_deployments" {
  statement {
    sid       = "2"
    effect    = "Allow"
    actions   = [
      "codedeploy:GetDeployment",
      "codedeploy:ListDeployments"
    ]
    resources = [ aws_codedeploy_deployment_group.this.arn ]
  }

  statement {
    sid       = "3"
    effect    = "Allow"
    actions   = [ "ssm:GetParameter" ]
    resources = [
      aws_ssm_parameter.database_host.arn,
      aws_ssm_parameter.database_name.arn,
      aws_ssm_parameter.database_username.arn,
      aws_ssm_parameter.database_password.arn
    ]
  }

  statement {
    sid       = "4"
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [ aws_kms_key.ssm_param_encrypt_key.arn ]
  }
}

data "aws_ami" "amazon_linux2" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [ local.ami_name ]
  }

  filter {
    name   = "architecture"
    values = [ local.ami_architecture ]
  }

  filter {
    name   = "virtualization-type"
    values = [ var.ami_virtualization ]
  }

  owners = [ local.ami_owner_id ]
}

data "aws_ssm_parameter" "admin_public_ssh_keys" {
  for_each = toset(var.admin_public_ssh_keys)

  name = each.value
  with_decryption = true
}

# ------------------- User data for cloud-init --------------------------
# The public ssh key will added to ec2 instances using cloud-init
data "cloudinit_config" "user_data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = templatefile("templates/userdata.tftpl", {
      public_ssh_keys: [ for key in data.aws_ssm_parameter.admin_public_ssh_keys: key.value]
    })
  }
}

