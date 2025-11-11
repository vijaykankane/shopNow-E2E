aws_region   = "ap-south-1"
aws_profile  = "tf-beginner"
project_name = "tf-aws-starter-prod"
tags = {
  Project     = "tf-aws-starter"
  Environment = "prod"
  Owner       = "platform-team"
}
db_backend            = "rds" # we'll use this much later
az_count              = 2
vpc_cidr              = "10.50.0.0/16"
public_subnet_newbits = 8