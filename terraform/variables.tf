variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-central-1"
}

variable "aws_profile" {
  type        = string
  description = "The AWS CLI profile to use"
  default     = "default"
}

variable "project_name" {
  type        = string
  description = "A short name for tagging and resource naming"
  default     = "vijay-aws-starter"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Project     = "vijay-aws-starter"
    Environment = "dev"
    Owner       = "vijay"
  }
}

variable "db_backend" {
  type        = string
  description = "Choose database backend for later lessons: rds or dynamodb"
  default     = "dynamodb"
  validation {
    condition     = contains(["rds", "dynamodb"], var.db_backend)
    error_message = "db_backend must be 'rds' or 'dynamodb'."
  }
}


# VPC CIDR as input (we used 10.42.0.0/16 earlier)
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.44.0.0/16"

  # Validate it's a proper CIDR by trying a harmless cidrsubnet
  validation {
    condition     = can(cidrsubnet(var.vpc_cidr, 0, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR, e.g. 10.42.0.0/16."
  }
}

# How many AZs/subnets we want to use right now
variable "az_count" {
  type        = number
  description = "How many Availability Zones (and subnets) to create"
  default     = 3
  validation {
    condition     = contains([1, 2, 3], var.az_count)
    error_message = "az_count must be 1, 2, or 3 for this starter."
  }
}

# Subnetting: how many new bits to carve /24s (8) out of /16 (16+8=24)
variable "public_subnet_newbits" {
  type        = number
  description = "Number of new bits to carve public subnets from the VPC CIDR (8 turns /16 into /24s)"
  default     = 8
  validation {
    condition     = var.public_subnet_newbits >= 4 && var.public_subnet_newbits <= 12
    error_message = "public_subnet_newbits should be between 4 and 12."
  }
}

# Placeholders for later (RDS). Declared now so you see 'sensitive' vars.
# They are not used yet, so you don't have to set them now.
variable "db_username" {
  type        = string
  description = "RDS username (used only when db_backend = \"rds\")"
  sensitive   = true
  default     = null
}

variable "db_password" {
  type        = string
  description = "RDS password (used only when db_backend = \"rds\")"
  sensitive   = true
  default     = null
}

# How we carve private subnets from the VPC CIDR (/16 -> /24 with 8 new bits)
variable "private_subnet_newbits" {
  type        = number
  description = "Number of new bits to carve private subnets from VPC CIDR"
  default     = 8
  validation {
    condition     = var.private_subnet_newbits >= 4 && var.private_subnet_newbits <= 12
    error_message = "private_subnet_newbits should be between 4 and 12."
  }
}


# Toggle creation of private subnets
variable "create_private_subnets" {
  type        = bool
  description = "Whether to create private subnets"
  default     = true
}

# NAT is OPTIONAL and costs money. Keep false while learning.
variable "create_nat_gateway" {
  type        = bool
  description = "Create a single NAT Gateway in one public subnet (dev only)"
  default     = true
}

# Which public subnet hosts the NAT (0-based index into your public subnets)
variable "nat_gateway_az_index" {
  type        = number
  description = "Index of public subnet/AZ to place the NAT Gateway (0-based)"
  default     = 1
  validation {
    condition     = var.nat_gateway_az_index >= 0 && var.nat_gateway_az_index <= var.az_count
    error_message = "nat_gateway_az_index must be within the number of AZs."
  }
}

variable "alb_ingress_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to hit the ALB (HTTP/HTTPS)"
  default     = ["0.0.0.0/0"]
}

# App port the ALB will forward to (your instance/listener target)
variable "app_port" {
  type        = number
  description = "Application port on the EC2 instances"
  default     = 80
}

# Optional SSH allow-list (empty = no SSH rule)
variable "allowlist_ssh_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH to app instances (empty disables SSH rule)"
  default     = []
}

# Database port (PostgreSQL by default)
variable "db_port" {
  type        = number
  description = "Database port to allow from app to DB (if RDS backend is selected)"
  default     = 5432
}

# Key pair handling
variable "create_key_pair" {
  type        = bool
  description = "Create an AWS key pair from the provided public key"
  default     = false
}

variable "key_pair_name" {
  type        = string
  description = "Name of the key pair to create or reference"
  default     = null
}

variable "public_key_openssh" {
  type        = string
  description = "Public key in OpenSSH format (used only when create_key_pair = true)"
  default     = null
  validation {
    condition     = var.create_key_pair ? can(regex("^ssh-(rsa|ed25519)", var.public_key_openssh)) : true
    error_message = "public_key_openssh must start with ssh-rsa or ssh-ed25519."
  }
}