provider "aws" {
  region = "us-east-1"  # Change this to your preferred region
}

# 1. Create VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "DevOps-VPC"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "DevOps-IGW"
  }
}

# 3. Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Ensure this matches your region
  tags = {
    Name = "DevOps-Public-Subnet"
  }
}

# 4. Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "DevOps-Public-RT"
  }
}

# 5. Associate Route Table with Subnet
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}