# One Elastic IP for the NAT (domain 'vpc' for modern provider versions)
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  // domain = "vpc"
  tags = {
    Name = "${local.name_prefix}-nat-eip"
  }
}

# Place a single NAT Gateway in the chosen public subnet (index into aws_subnet.public[*])
resource "aws_nat_gateway" "this" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.nat_gateway_az_index].id
  tags = {
    Name = "${local.name_prefix}-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

# One private route table for all private subnets (simple + cheap for dev)
resource "aws_route_table" "private" {
  count  = var.create_private_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

# Default route from private subnets to the NAT (only if NAT exists)
resource "aws_route" "private_to_nat" {
  count                  = var.create_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

# Associate all private subnets to the private route table
resource "aws_route_table_association" "private" {
  count          = var.create_private_subnets ? var.az_count : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}