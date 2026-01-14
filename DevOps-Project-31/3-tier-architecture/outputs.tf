# outputs.tf

output "web_tier_alb_url" {
  description = "Public URL for the Web Tier"
  value       = "http://${module.web_tier.alb_dns_name}"
}

output "rds_endpoint" {
  description = "Internal endpoint for the Database"
  value       = module.database.db_endpoint
}