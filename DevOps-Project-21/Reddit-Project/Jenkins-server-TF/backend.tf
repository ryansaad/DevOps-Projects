terraform {
  backend "s3" {
    bucket         = "devops-day-27-project-tf-state-12345"
    region         = "us-east-1"
    key            = "Reddit-Project/Jenkins-Server-TF/terraform.tfstate"
    dynamodb_table = "lock-table"
    encrypt        = true
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}
