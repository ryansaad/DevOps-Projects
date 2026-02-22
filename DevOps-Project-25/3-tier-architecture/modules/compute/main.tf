# Logic to determine which subnets to use
# If public_subnets are provided, use them. Otherwise, use private_subnets.
locals {
  subnet_ids = length(var.public_subnets) > 0 ? var.public_subnets : var.private_subnets
}

# 1. Target Group
# This is where the Load Balancer sends traffic.
resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-${var.tier_name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.tier_name == "app" ? "/health" : "/" # Adjust path based on tier
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 2. Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.tier_name}-alb"
  internal           = var.is_internal_alb # <--- The magic switch
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = local.subnet_ids

  tags = {
    Name = "${var.project_name}-${var.tier_name}-alb"
  }
}

# 3. ALB Listener
# Listens on Port 80 and forwards to the Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# 4. Launch Template
# Defines the configuration of the EC2 instances
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project_name}-${var.tier_name}-lt-"
  image_id      = var.ami_id
  instance_type = "t2.micro" # Free tier eligible

  network_interfaces {
    associate_public_ip_address = var.is_internal_alb ? false : true # Only public if ALB is external (simplified logic)
    security_groups             = [var.security_group_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.tier_name}-instance"
    }
  }
}

# 5. Auto Scaling Group (ASG)
# Manages the instances
resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-${var.tier_name}-asg"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = local.subnet_ids
  target_group_arns   = [aws_lb_target_group.tg.arn] # Attach to LB

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.tier_name}-asg"
    propagate_at_launch = true
  }
}