# Main Terraform configuration for AWS infrastructure

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    # Update these values according to your setup
    bucket = "ryans-terraform-state-001"
    key    = "java-app/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment     = var.environment
  vpc_cidr       = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs            = var.availability_zones
}

# Security Module
module "security" {
  source = "./modules/security"

  environment = var.environment
  vpc_id     = module.vpc.vpc_id
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  environment         = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.db_security_group_id]
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnet_ids  # <--- Changed from 'public_subnets'
  security_group_ids = [module.security.alb_security_group_id]
}

# Auto Scaling Group Module
module "asg" {
  source = "./modules/asg"

  environment         = var.environment
  instance_type       = var.instance_type
  key_name            = var.key_name
  
  # Networking & Security
  security_group_ids  = [module.security.app_security_group_id]
  private_subnet_ids  = module.vpc.private_subnet_ids
  
  # Scaling Config
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity

  # Load Balancer Connection (Where traffic comes from)
  target_group_arns   = [module.alb.target_group_arn]

  # Artifact Warehouse (Where code comes from)
  codeartifact_domain = module.artifact.domain
  codeartifact_owner  = module.artifact.domain_owner
  codeartifact_url    = module.artifact.repository_endpoint


  # PASS THE DATABASE DETAILS HERE
  project_name      = var.project_name
 
  
  # The Fix: Pointing to the database that ACTUALLY exists
  db_endpoint       = module.rds.rds_endpoint
  db_name           = "javaapp"    # <--- CHANGE THIS from "webappdb" to "javaapp"
  db_user           = var.db_username
  db_password       = var.db_password
}

# CloudWatch Module
# module "monitoring" {
#  source = "./modules/monitoring"

#  environment = var.environment
#  rds_instance_id = module.rds.rds_instance_id
#  asg_name = module.asg.asg_name
# } 


module "artifact" {
  source = "./modules/artifact"
  environment = var.environment
}

module "bastion" {
  source = "./modules/bastion"

  environment        = var.environment
  key_name           = var.key_name
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security.bastion_security_group_id]
}