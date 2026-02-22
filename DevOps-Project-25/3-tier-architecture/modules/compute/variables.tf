variable "project_name" {
  type = string
}

variable "tier_name" {
  description = "Name of the tier (e.g., 'web' or 'app')"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  description = "List of public subnet IDs (used for Web Tier)"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet IDs (used for App Tier)"
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "Security Group for the EC2 instances"
  type        = string
}

variable "alb_security_group" {
  description = "Security Group for the Load Balancer"
  type        = string
}

variable "is_internal_alb" {
  description = "Boolean to determine if ALB is internal or internet-facing"
  type        = bool
}

variable "ami_id" {
  description = "The AMI ID to launch (Baked Web or App image)"
  type        = string
}

variable "target_port" {
  description = "Port the application listens on (80 for Web, 4000 for App)"
  type        = number
}