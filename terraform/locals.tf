locals {
  # Derive a consistent name prefix from project and environment tag
  name_prefix = "${var.project_name}-${var.tags["Environment"]}"

  # Take the first N AZs in this region
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Precompute the public subnet CIDRs we will use (one per AZ)
  public_subnet_cidrs = [
    for i in range(var.az_count) :
    cidrsubnet(var.vpc_cidr, var.public_subnet_newbits, i)
  ]

  # Private subnets: use a distinct index range so they don't overlap public ones.
  # Example: start at 100 to keep numbers easy to reason about.
  private_subnet_cidrs = [
    for i in range(var.az_count) :
    cidrsubnet(var.vpc_cidr, var.private_subnet_newbits, 100 + i)
  ]
}