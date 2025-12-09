# --- 1. IAM Role for App Servers (So they can download artifacts) ---
resource "aws_iam_role" "app_role" {
  name = "${var.environment}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "app_policy" {
  name = "codeartifact-read"
  role = aws_iam_role.app_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codeartifact:GetAuthorizationToken",
        "codeartifact:GetRepositoryEndpoint",
        "codeartifact:ReadFromRepository",
        "sts:GetServiceBearerToken"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.environment}-app-profile"
  role = aws_iam_role.app_role.name
}

# --- 2. The Launch Template (The Blueprint) ---
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-lt"
  image_id      = "ami-0e2c8caa4b6378d8c" # Ubuntu 24.04 (us-east-1)
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openjdk-11-jdk maven unzip

              # 1. Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              # 2. Authenticate with CodeArtifact
              export TOKEN=$(aws codeartifact get-authorization-token --domain ${var.codeartifact_domain} --domain-owner ${var.codeartifact_owner} --region us-east-1 --query authorizationToken --output text)

              # 3. Create Settings file
              cat > settings.xml <<XML
              <settings>
                <servers>
                  <server>
                    <id>codeartifact</id>
                    <username>aws</username>
                    <password>$TOKEN</password>
                  </server>
                </servers>
              </settings>
              XML

              # 4. Download the App
              mvn dependency:get -s settings.xml \
                -DremoteRepositories=codeartifact::::${var.codeartifact_url} \
                -Dartifact=com.devopsrealtime:dptweb:1.1:war \
                -Dtransitive=false \
                -Ddest=app.war

              # 5. Run the App (WITH CORRECT VARIABLES)
              # Note the 'var.' prefix below!
              java -jar /app.war --spring.datasource.url=jdbc:mysql://${var.db_endpoint}:3306/${var.db_name} --spring.datasource.username=${var.db_user} --spring.datasource.password=${var.db_password} --server.port=8080
              EOF
  )
}

# --- 3. The Auto Scaling Group (The Manager) ---
resource "aws_autoscaling_group" "main" {
  name                = "${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  target_group_arns   = var.target_group_arns

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-app-asg"
    propagate_at_launch = true
  }
}