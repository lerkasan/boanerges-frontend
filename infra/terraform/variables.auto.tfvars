//allowed_account_ids    = [ "Put your AWS account ID here" ]
//admin_public_ip        = [ "Put your public IP here" ]   or you can skip it and IP will be automatically obtained
admin_public_ssh_keys    = [ "admin_public_ssh_key", "lerkasan_ssh_public_key_bastion" ]
appserver_private_ssh_key_name   = "appserver_ssh_key"

aws_region               = "us-east-1"
az_letters               = [ "a", "b" ]

environment              = "stage"
project_name             = "boanerges"

alb_logs_s3_bucket_name  = "boanerges-demo-alb-logs"

state_s3_bucket_name     = "boanerges-demo-terraform-state"
state_s3_filepath        = "demo/terraform.tfstate"

cidr                     = "10.0.0.0/16"
public_subnets           = [ "10.0.10.0/24", "10.0.20.0/24" ]
private_subnets          = [ "10.0.240.0/24", "10.0.250.0/24" ]

ec2_instance_type        = "t2.micro"
os                       = "ubuntu"
os_product               = "server"
os_version               = "22.04"
os_architecture          = "amd64"
ami_virtualization       = "hvm"
#ami_name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

rds_name                 = "demo-db"
database_engine          = "mysql"
database_engine_version  = "8.0.32"
database_instance_class  = "db.t3.micro"


