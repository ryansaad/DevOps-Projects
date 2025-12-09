output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "The ID of the Target Group (used by ASG)"
  value       = aws_lb_target_group.app.arn
}