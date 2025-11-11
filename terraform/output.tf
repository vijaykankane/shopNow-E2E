output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "chosen_db_backend" {
  description = "Which DB option this stack is set to use later"
  value       = var.db_backend
}
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}



output "public_subnet_cidrs" {
  description = "CIDRs of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}



output "azs_used" {
  description = "Availability Zones used for public subnets"
  value       = local.azs
}

output "public_subnets_struct" {
  description = "List of objects with id/az/cidr for each public subnet"
  value = [
    for idx, s in aws_subnet.public :
    {
      index = idx + 1
      id    = s.id
      az    = local.azs[idx]
      cidr  = s.cidr_block
    }
  ]
}

# Public networking artifacts
output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

# Private subnet details (if created)
output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = try(aws_subnet.private[*].id, [])
}

output "private_subnet_cidrs" {
  description = "CIDRs of private subnets"
  value       = try(aws_subnet.private[*].cidr_block, [])
}

# NAT details (if created)
output "nat_gateway_id" {
  description = "NAT Gateway ID (if enabled)"
  value       = var.create_nat_gateway ? aws_nat_gateway.this[0].id : null
}

output "nat_eip_allocation_id" {
  description = "NAT EIP allocation ID (if enabled)"
  value       = var.create_nat_gateway ? aws_eip.nat[0].id : null
}

output "private_route_table_id" {
  description = "Private route table ID (if private subnets enabled)"
  value       = (var.create_private_subnets ? aws_route_table.private[0].id : null)
}