resource "aws_db_instance" "primary" {
  storage_type            = "gp2"
  allocated_storage       = 10
  max_allocated_storage   = 20
  backup_retention_period = 30
//deletion_protection     = true
  identifier              = var.rds_name
  engine                  = var.database_engine
  engine_version          = var.database_engine_version
  instance_class          = var.database_instance_class
  db_name                 = aws_ssm_parameter.database_name.value
  username                = aws_ssm_parameter.database_username.value
  password                = aws_ssm_parameter.database_password.value
//multi_az                = true      # commented because it adds additional 15-20 minutes to create RDS instance
  availability_zone       = local.availability_zones[0]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [ aws_security_group.database.id ]
  publicly_accessible     = false
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.database_encrypt_key.arn    # or storage_encrypted = true See documentation
  maintenance_window      = "Sun:02:00-Sun:04:00"
  enabled_cloudwatch_logs_exports = [ "error", "slowquery" ]     # audit, error, general, slowquery
  skip_final_snapshot     = true

  tags = {
    Name        = join("_", [var.project_name, "_primary_db"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_db_subnet_group" "this" {
  name          = join("_", [var.project_name, "_db_subnet_group"])
  subnet_ids    = [ for subnet in aws_subnet.private : subnet.id ]

  tags = {
    Name        = join("_", [var.project_name, "_db_subnet_group"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "database" {
  name        = join("_", [var.project_name, "_db_security_group"])
  description = "Demo security group for database"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name        = join("_", [var.project_name, "_database_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }

  # Dependency is used to ensure that VPC has NAT gateways
  depends_on  = [ aws_nat_gateway.this ]
}

resource "aws_kms_key" "database_encrypt_key" {
  description             = "A key to encrypt database"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = join("_", [var.project_name, "_database_encrypt_key"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_kms_key" "ssm_param_encrypt_key" {
  description             = "A key to encrypt SSM parameters"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = join("_", [var.project_name, "_ssm_param_encrypt_key"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_kms_grant" "decrypt_access_for_ec2" {
  name              = "decrypt_access_for_ec2_boanerges"
  key_id            = aws_kms_key.ssm_param_encrypt_key.id
  grantee_principal = aws_iam_role.appserver_iam_role.arn
  operations        = [ "Decrypt" ]
}

resource "aws_ssm_parameter" "database_host" {
  name        = join("_", [var.project_name, "database_host"])
  description = "Demo database host"
  type        = "SecureString"
  key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value       = aws_db_instance.primary.address

  tags = {
    Name        = join("_", [var.project_name, "database_host"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "database_name" {
  name        = join("_", [var.project_name, "database_name"])
  description = "Demo database name"
  type        = "SecureString"
  key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value       = var.database_name

  tags = {
    Name        = join("_", [var.project_name, "database_name"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "database_username" {
  name        = join("_", [var.project_name, "database_username"])
  description = "Demo database username"
  type        = "SecureString"
  key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value       = var.database_username

  tags = {
    Name        = join("_", [var.project_name, "database_username"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "database_password" {
  name        = join("_", [var.project_name, "database_password"])
  description = "Demo database password"
  type        = "SecureString"
  key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value       = var.database_password

  tags = {
    Name        = join("_", [var.project_name, "database_password"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

//# Read replica - commented because it adds additional 15-20 minutes to create RDS instance
//resource "aws_db_instance" "read_replica" {
//  identifier                      = "db-read-replica"
//  replicate_source_db             = aws_db_instance.primary.identifier
//  kms_key_id                      = aws_kms_key.database_encrypt_key.arn
//  instance_class                  = var.database_instance_class
//  storage_type                    = "gp2"
//  max_allocated_storage           = 30
//  backup_retention_period         = 30
//  apply_immediately               = false
//  publicly_accessible             = false
//  multi_az                        = true
////db_subnet_group_name            = aws_db_subnet_group.this.name
//  vpc_security_group_ids          = [ aws_security_group.database.id ]
//  enabled_cloudwatch_logs_exports = [ "error", "slowquery" ]
//  skip_final_snapshot             = true
//
//  tags = {
//    Name        = "read_replica"
//    terraform   = "true"
//    environment = var.environment
//    project     = var.project_name
//  }
//}