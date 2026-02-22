output "alb_external_sg_id" {
  value = aws_security_group.alb_external.id
}

output "web_sg_id" {
  value = aws_security_group.web_tier.id
}

output "alb_internal_sg_id" {
  value = aws_security_group.alb_internal.id
}

output "app_sg_id" {
  value = aws_security_group.app_tier.id
}

output "db_sg_id" {
  value = aws_security_group.db_tier.id
}