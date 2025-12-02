variable "environment" {}
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}