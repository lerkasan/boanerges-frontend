#variable "allowed_account_ids" {
#  description = "List of allowed AWS account ids where resources can be created"
#  type        = list(string)
#  sensitive   = true
#}

variable "aws_region" {
  description   = "AWS region"
  type          = string
  default       = "us-east-1"
}

variable "state_s3_bucket_name" {
  description   = "Terraform state S3 bucket"
  type          = string
  default       = "boanerges-terraform-state"
}

variable "project_name" {
  description   = "Project name"
  type          = string
  default       = "boanerges"
}
