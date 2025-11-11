# security_groups.tf

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB ingress from internet, egress anywhere"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# ALB ingress rules (HTTP 80 and HTTPS 443) from configured CIDRs
resource "aws_security_group_rule" "alb_http_in" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidrs
  description       = "HTTP from allowed CIDRs"
}

resource "aws_security_group_rule" "alb_https_in" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidrs
  description       = "HTTPS from allowed CIDRs"
}

# App (EC2) Security Group
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "App instances: inbound only from ALB on app port, optional SSH"
  vpc_id      = aws_vpc.main.id

  # default egress all (instances can reach out; in private subnets this goes via NAT if enabled)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-app-sg"
  }
}

# App ingress from ALB on app_port
resource "aws_security_group_rule" "app_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "App traffic from ALB"
}

# Optional SSH to app from allow-listed CIDRs (created only if list is non-empty)
resource "aws_security_group_rule" "app_ssh_in" {
  count             = length(var.allowlist_ssh_cidrs) > 0 ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.app.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowlist_ssh_cidrs
  description       = "SSH from allow-listed CIDRs"
}

# DB Security Group (only if RDS backend)
resource "aws_security_group" "db" {
  count       = var.db_backend == "rds" ? 1 : 0
  name        = "${local.name_prefix}-db-sg"
  description = "DB: inbound only from app SG"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-db-sg"
  }
}

# Allow app -> DB on db_port
resource "aws_security_group_rule" "db_from_app" {
  count                    = var.db_backend == "rds" ? 1 : 0
  type                     = "ingress"
  security_group_id        = aws_security_group.db[0].id
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "DB traffic from app SG"
}