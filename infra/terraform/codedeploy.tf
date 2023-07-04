resource "aws_codedeploy_app" "this" {
  name = var.project_name

  tags = {
    Name        = join("_", [var.project_name, "_appserver"])
    terraform   = "true"
    project     = var.project_name
  }
}

data "aws_iam_policy_document" "assume_role_codedeploy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codedeploy" {
  name               = "codedeployRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_codedeploy.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy.name
}

#resource "aws_sns_topic" "example" {
#  name = "example-topic"
#}

#resource "aws_codedeploy_deployment_config" "this" {
#  deployment_config_name = "boanerges-deployment-config"
#
#  minimum_healthy_hosts {
#    type  = "HOST_COUNT"
#    value = 2
#  }
#}

resource "aws_codedeploy_deployment_group" "this" {
  app_name                = aws_codedeploy_app.this.name
  deployment_group_name   = "production"
  service_role_arn        = aws_iam_role.codedeploy.arn
  deployment_config_name  = "CodeDeployDefault.OneAtATime"
#  deployment_config_name = aws_codedeploy_deployment_config.this.id

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
#    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
      target_group_info {
        name = aws_lb_target_group.app.name
      }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = var.project_name
    }

    ec2_tag_filter {
      key   = "project"
      type  = "KEY_AND_VALUE"
      value = var.project_name
    }
  }

  tags = {
    Name        = join("_", [var.project_name, "_appserver"])
    terraform   = "true"
    project     = var.project_name
  }


#  blue_green_deployment_config {
#    deployment_ready_option {
#      action_on_timeout    = "STOP_DEPLOYMENT"
#      wait_time_in_minutes = 60
#    }
#
#    green_fleet_provisioning_option {
#      action = "DISCOVER_EXISTING"
#    }
#
#    terminate_blue_instances_on_deployment_success {
#      action = "KEEP_ALIVE"
#    }
#  }


#  trigger_configuration {
#    trigger_events     = ["DeploymentFailure"]
#    trigger_name       = "example-trigger"
#    trigger_target_arn = aws_sns_topic.example.arn
#  }

#  alarm_configuration {
#    alarms  = ["my-alarm-name"]
#    enabled = true
#  }
}

