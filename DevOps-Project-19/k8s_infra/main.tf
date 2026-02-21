provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "k8s_traffic" {
  name        = "k8s_traffic_allow"
  description = "Allow all traffic for K8s learning lab"

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

# --- MASTER NODE ---
resource "aws_instance" "k8s_master" {
  # PASTE THE AMI ID THAT WORKED FOR JENKINS HERE (e.g., ami-04b70...)
  ami             = "ami-0ecb62995f68bb549" 
  instance_type   = "t2.medium" # Master needs 2 vCPUs
  key_name        = "DevOpss"
  security_groups = [aws_security_group.k8s_traffic.name]
  
  tags = {
    Name = "k8s-master"
  }
}

# --- WORKER NODE ---
resource "aws_instance" "k8s_worker" {
  # PASTE THE SAME AMI ID HERE
  ami             = "ami-0ecb62995f68bb549"
  instance_type   = "t2.medium" # Worker needs 2 vCPUs
  key_name        = "DevOpss"
  security_groups = [aws_security_group.k8s_traffic.name]

  tags = {
    Name = "k8s-slave" # The tutorial calls it 'slave' or 'worker'
  }
}