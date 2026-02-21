# 🚀 DevOps Project to Automate Infrastructure on AWS Using Terraform and GitLab CICD

Before starting, ensure you have a basic understanding of:

* Basic Terraform Knowledge

* Understanding of CI/CD

* GitLab CI Knowledge

This project demonstrates the automation of AWS infrastructure provisioning using **Terraform** and **GitLab CI/CD**. It transitions from manual Infrastructure as Code (IaC) execution to a fully automated, production-grade deployment pipeline. 

By leveraging modularized Terraform code and remote state management, this project ensures secure, repeatable, and scalable cloud deployments.

## 🛠️ Skills & Technologies Demonstrated
* **Cloud Provider:** AWS (VPC, Subnets, Security Groups, EC2, S3, DynamoDB)
* **Infrastructure as Code (IaC):** Terraform (HCL)
* **CI/CD Automation:** GitLab CI/CD (`.gitlab-ci.yml`)
* **State Management:** S3 Remote Backend with DynamoDB State Locking
* **Best Practices:** Code modularization, secure credential injection, and automated validation/planning.

## 🏗️ Architecture & Workflow
1. **Code Commit:** Developer pushes modularized Terraform code to the GitLab repository.
2. **Pipeline Trigger:** GitLab CI/CD automatically triggers the pipeline.
3. **Validation & Planning:** The pipeline initializes Terraform, validates the syntax, and generates an execution plan (`terraform plan`).
4. **Manual Approval:** The deployment step (`terraform apply`) is paused pending manual approval for safety.
5. **State Management:** Terraform communicates securely with an AWS S3 bucket to store the `.tfstate` file, utilizing DynamoDB to lock the state and prevent concurrent modification conflicts.
6. **Provisioning:** Upon approval, AWS resources (VPC network and EC2 instance) are provisioned.

## 📂 Project Structure
```text
cicdtf/
├── .gitlab-ci.yml    # GitLab CI/CD Pipeline definition
├── main.tf           # Root configuration calling modules
├── provider.tf       # AWS provider configuration
├── backend.tf        # S3 and DynamoDB remote state config
├── vpc/              # Network Module
│   ├── main.tf       # VPC, Subnet, and Security Group setup
│   └── outputs.tf    # Outputs to pass to the compute module
└── web/              # Compute Module
    ├── main.tf       # EC2 Instance setup
    └── variables.tf  # Input variables from the VPC module



