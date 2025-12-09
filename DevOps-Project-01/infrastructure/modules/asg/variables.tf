variable "project_name" {}
variable "environment" {}

variable "instance_type" {}
variable "key_name" {}
variable "security_group_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

# ASG Sizing
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}

# Load Balancer Attachment
variable "target_group_arns" { type = list(string) }

# CodeArtifact
variable "codeartifact_domain" {}
variable "codeartifact_owner" {}
variable "codeartifact_url" {}

# Database Connection (Crucial for the fix!)
variable "db_endpoint" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" {}