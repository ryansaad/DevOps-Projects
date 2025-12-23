variable "key_name" {
  default = "DevOpss" # <--- MAKE SURE THIS KEY EXISTS IN AWS CONSOLE
}

variable "ami_id" {
  default = "ami-04b70fa74e45c3917" # Ubuntu 24.04 LTS in us-east-1. Update if needed.
}

# 1. Ansible Controller
resource "aws_instance" "ansible_controller" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "Ansible-Controller"
  }
}

# 2. Jenkins Master
resource "aws_instance" "jenkins_master" {
  ami           = var.ami_id
  instance_type = "t2.medium" # Needs RAM for Jenkins + SonarQube
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "Jenkins-Master"
  }
}

# 3. Jenkins Agent
resource "aws_instance" "jenkins_agent" {
  ami           = var.ami_id
  instance_type = "t2.medium" # Needs RAM for builds
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "Jenkins-Agent"
  }
}