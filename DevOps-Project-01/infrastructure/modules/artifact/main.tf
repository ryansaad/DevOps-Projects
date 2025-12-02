resource "aws_codeartifact_domain" "main" {
  domain = "${var.environment}-domain"
}

resource "aws_codeartifact_repository" "maven" {
  repository = "maven-repo"
  domain     = aws_codeartifact_domain.main.domain
  
  # Connects this repo to the official public Maven Central (so it can download public jars)
  external_connections {
    external_connection_name = "public:maven-central"
  }
}

# Fetch the Maven Endpoint URL
data "aws_codeartifact_repository_endpoint" "maven" {
  domain      = aws_codeartifact_domain.main.domain
  repository  = aws_codeartifact_repository.maven.repository
  format      = "maven"
}