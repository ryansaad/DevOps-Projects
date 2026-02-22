variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.medium" 
  # Note: t2.micro is too small for Jenkins + SonarQube. use t2.medium (4GB RAM)
}

variable "key_name" {
  description = "The name of your EC2 Key Pair (create this in AWS Console first)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 in us-east-1"
  default     = "ami-0c7217cdde317cfec" 
  # If you are NOT in us-east-1, you must find the Ubuntu 22.04 AMI ID for your region.
}