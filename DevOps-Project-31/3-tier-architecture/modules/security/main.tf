# 1. External ALB Security Group
# The Entry Point. Allows traffic from the entire internet.
resource "aws_security_group" "alb_external" {
  name        = "${var.project_name}-alb-external-sg"
  description = "Allow HTTP inbound traffic from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-external-sg"
  }
}

# 2. Web Tier Security Group
# Only accepts traffic from the External ALB.
resource "aws_security_group" "web_tier" {
  name        = "${var.project_name}-web-tier-sg"
  description = "Allow traffic from External ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from External ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_external.id] # <--- The Link
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-tier-sg"
  }
}

# 3. Internal ALB Security Group
# Acts as the traffic cop between Web and App tiers.
resource "aws_security_group" "alb_internal" {
  name        = "${var.project_name}-alb-internal-sg"
  description = "Allow traffic from Web Tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Web Tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id] # <--- The Link
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-internal-sg"
  }
}

# 4. App Tier Security Group
# The backend logic. Only accepts traffic from the Internal ALB.
resource "aws_security_group" "app_tier" {
  name        = "${var.project_name}-app-tier-sg"
  description = "Allow traffic from Internal ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Custom TCP from Internal ALB"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_internal.id] # <--- The Link
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-tier-sg"
  }
}

# 5. Database Security Group
# The Vault. Only accepts traffic from the App Tier.
resource "aws_security_group" "db_tier" {
  name        = "${var.project_name}-db-tier-sg"
  description = "Allow MySQL traffic from App Tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from App Tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id] # <--- The Link
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-tier-sg"
  }
}