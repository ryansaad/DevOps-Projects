# Provider configuration
provider "aws" {
  region = "us-east-1" # <--- CHANGE THIS to your region (e.g., "us-east-1")
}

# Create a new security group that allows all inbound and outbound traffic
# NOTE: In a real production environment, opening port 0-65535 to 0.0.0.0/0 is insecure.
# For this learning lab, it prevents connection issues.
resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Security group that allows all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
  resource "aws_instance" "my_ec2_instance" {
  # <--- CRITICAL: Get the AMI ID for Ubuntu 22.04 in YOUR region from AWS Console
  ami             = "ami-0ecb62995f68bb549" 
  instance_type   = "t2.large" # Costs money. 
  key_name        = "DevOpss" # <--- Ensure this Key Pair exists in your AWS Console
  security_groups = [aws_security_group.allow_all.name]

  # Configure root block device
  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "MyUbuntuInstance"
  }
}