# variables.tf

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "three-tier-demo"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "web_ami_id" {
  description = "The AMI ID for the Web Tier (Nginx)"
  type        = string
}

variable "app_ami_id" {
  description = "The AMI ID for the App Tier (Node.js)"
  type        = string
}