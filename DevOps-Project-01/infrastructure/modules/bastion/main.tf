# 1. Define the IAM Role (The "Badge" that allows access)
resource "aws_iam_role" "bastion_role" {
  name = "${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Add Permissions to the Role (What the Badge allows you to do)
resource "aws_iam_role_policy" "codeartifact_policy" {
  name = "codeartifact-access"
  role = aws_iam_role.bastion_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata",
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# 3. Create the Instance Profile (The wrapper to attach the Role to EC2)
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.environment}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

# 4. Create the EC2 Instance (The actual server)
resource "aws_instance" "bastion" {
  ami                         = "ami-0e2c8caa4b6378d8c" # Ubuntu 24.04 LTS
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  
  # This attaches the permissions we created above
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name

  tags = {
    Name = "${var.environment}-bastion"
  }
}