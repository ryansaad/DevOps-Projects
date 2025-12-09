variable "environment" {}
variable "vpc_id" {}
variable "subnets" {
  type        = list(string)
  description = "List of Public Subnet IDs"
}
variable "security_group_ids" {
  type        = list(string)
  description = "Security Group for the ALB"
}