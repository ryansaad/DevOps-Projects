# 1. The Load Balancer (The Entry Point)
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnets

  tags = {
    Name = "${var.environment}-alb"
  }
}

# 2. The Listener (Listens on Port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# 3. The Target Group (Where to send the traffic)
resource "aws_lb_target_group" "app" {
  name     = "${var.environment}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"    # Checks if the homepage loads
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    matcher             = "200"  # Expects a "200 OK" success code
  }
}