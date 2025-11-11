aws_region   = "eu-central-1"
aws_profile  = "default"
project_name = "tf-aws-starter-dev"
tags = {
  Project     = "tf-aws-starter"
  Environment = "dev"
  Owner       = "vijay"
}
db_backend            = "dynamodb"
az_count              = 2
vpc_cidr              = "10.43.0.0/16"
public_subnet_newbits = 4

# Open ALB to the world for now (lock down later)
alb_ingress_cidrs = ["0.0.0.0/0"]

# No SSH by default (use SSM later). To SSH, set your IP here.
allowlist_ssh_cidrs = []

# Key pair: either create from a public key or reference one by name
create_key_pair = false
key_pair_name   = "vktravel" # ensure this exists in your region

# If creating one instead:
# create_key_pair     = true
# key_pair_name       = "tf-aws-starter-dev-key"
# public_key_openssh  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your_email@example.com"