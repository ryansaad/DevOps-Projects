output "repository_endpoint" {
  value = data.aws_codeartifact_repository_endpoint.maven.repository_endpoint
}

output "domain" {
  value = aws_codeartifact_domain.main.domain
}

output "domain_owner" {
  value = aws_codeartifact_domain.main.owner
}