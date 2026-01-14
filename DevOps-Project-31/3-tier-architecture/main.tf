# main.tf

# 1. Networking Module
# Creates the network foundation (VPC, Subnets, Gateways)
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  # We will define these variables later
}

# 2. Security Module
# Creates the "Chained Security Groups"
module "security" {
  source = "./modules/security"

  vpc_id = module.vpc.vpc_id  # Dependency: Needs VPC to exist first
}

# 3. Database Module
# Creates the RDS MySQL instance
module "database" {
  source = "./modules/database"

  vpc_id              = module.vpc.vpc_id
  db_subnet_ids       = module.vpc.private_db_subnet_ids # Isolation
  db_security_group_id = module.security.db_sg_id       # Access Control
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
}

# 4. Web Tier (Frontend)
# Creates ALB, Target Group, and Auto Scaling Group for Nginx
module "web_tier" {
  source = "./modules/compute"

  tier_name           = "web"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnet_ids
  private_subnets     = [] # Web tier lives in public subnets (or behind ALB)
  security_group_id   = module.security.web_sg_id
  alb_security_group  = module.security.alb_external_sg_id
  is_internal_alb     = false # External LB
  ami_id              = var.web_ami_id
  target_port         = 80
}

# 5. App Tier (Backend)
# Creates Internal ALB, ASG for Node.js
module "app_tier" {
  source = "./modules/compute"

  tier_name           = "app"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = [] 
  private_subnets     = module.vpc.private_app_subnet_ids
  security_group_id   = module.security.app_sg_id
  alb_security_group  = module.security.alb_internal_sg_id
  is_internal_alb     = true # Internal LB
  ami_id              = var.app_ami_id # The AMI we baked manually earlier
  target_port         = 4000
}