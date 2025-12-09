output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = module.bastion.public_ip
}

output "codeartifact_url" {
  description = "The Maven repository URL"
  value       = module.artifact.repository_endpoint
}

output "codeartifact_domain" {
  value = module.artifact.domain
}

output "codeartifact_owner" {
  value = module.artifact.domain_owner
}

output "alb_dns_name" {
  description = "The public URL of the Load Balancer"
  value       = module.alb.alb_dns_name
}