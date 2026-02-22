## 🤖 Terraform Implementation (Infrastructure as Code)

This project includes a fully modularized Terraform setup to automate the provisioning of the 3-Tier Architecture.

### 📂 Terraform Structure
The infrastructure is broken down into logical modules to promote reusability and isolation:

* **`main.tf`**: The root configuration that ties all modules together.
* **`modules/vpc`**: Provisions the 6 subnets, Internet Gateway, 2 NAT Gateways, and Route Tables.
* **`modules/security`**: Implements the "Chained Security Group" pattern (ALB -> Web -> Internal ALB -> App -> DB).
* **`modules/database`**: Provisions the RDS MySQL instance and Subnet Groups.
* **`modules/compute`**: A polymorphic module that handles **both** the Web Tier (External ALB + Nginx) and App Tier (Internal ALB + Node.js) based on inputs.

### 🥚 The "Chicken and Egg" Problem
When automating 3-Tier architectures with "Golden AMIs" (pre-baked images), you will encounter a circular dependency known as the Chicken and Egg problem.

**The Loop:**
1.  **The Code Needs the DB:** The Node.js application config file requires the **RDS Endpoint** to connect to the database.
2.  **The AMI Needs the Code:** To bake the App Tier AMI, you must save the configuration (with the endpoint) onto the server.
3.  **Terraform Needs the AMI:** To launch the App Tier ASG, Terraform requires the **AMI ID**.
4.  **The DB Needs Terraform:** The RDS Endpoint is only generated **after** Terraform creates the database resource.

**You cannot bake the AMI with the correct DB endpoint because the DB doesn't exist yet. But you cannot deploy the full stack without the AMI.**

### 🛠 Solutions

#### Solution A: The Hybrid Approach (Used in this Lab)
This is the easiest way to transition from manual to automated.
1.  **Step 1:** Run Terraform to provision the **Network** and **Database** layers only.
2.  **Step 2:** Retrieve the new RDS Endpoint from the Terraform output.
3.  **Step 3:** Manually launch a temporary EC2, update the application config with this new endpoint, and bake a new **App Tier AMI**.
4.  **Step 4:** Update `terraform.tfvars` with this new AMI ID and run Terraform again to deploy the **Compute** layer.

#### Solution B: The "User Data" Approach (Fully Automated)
This is the advanced DevOps method (Level 2) which removes the need for hard-baking configurations.
1.  Use a generic AMI that contains the code but **no configuration**.
2.  Pass the RDS Endpoint as a variable into the **EC2 User Data** (startup script) via Terraform.
3.  When the instance boots, the script dynamically writes the `.env` file or environment variables using the endpoint provided by Terraform.

### 🚀 Usage
1.  **Initialize:** `terraform init`
2.  **Plan:** `terraform plan`
3.  **Apply:** `terraform apply -auto-approve`
    * *Note:* Database creation may take 5-10 minutes.
4.  **Destroy:** `terraform destroy -auto-approve`



---------------------------------------------------------------------
# 🚀 Advanced: Automating Configuration (Solving the Chicken-Egg Problem)

To avoid manually re-baking AMIs every time the database endpoint changes, we use **EC2 User Data**. This injects the database credentials into the application at runtime (boot time), effectively decoupling the "code" (AMI) from the "configuration" (Terraform).

## 1. Create the Setup Script
Create a file named `app-tier-setup.sh` in your root directory. This script runs automatically when the instance boots, creates the `.env` file with the correct database address, and restarts the app.

**File:** `app-tier-setup.sh`
```bash
#!/bin/bash
# app-tier-setup.sh

# 1. Capture the inputs passed from Terraform
# Terraform replaces these ${} placeholders with actual values
DB_HOST="${db_host}"
DB_USER="${db_user}"
DB_PASS="${db_password}"
DB_NAME="${db_name}"

# 2. Navigate to the application directory
# (Ensure this matches the path where your code lives in the AMI)
cd /home/ec2-user/app-tier

# 3. Create the Environment File
cat <<EOT > .env
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_NAME=$DB_NAME
PORT=4000
EOT

# 4. Restart the Application
# Uses PM2 to pick up the new .env configuration
pm2 restart all || pm2 start index.js --name "app-tier"

echo "App Tier Configuration Complete!"


---------------------------------
modules/compute/variables.tf
# variable "user_data_script" {
#   description = "The shell script to run on instance boot"
#   type        = string
#   default     = "" 
# }

modules/compute/main.tf
# resource "aws_launch_template" "lt" {
#   # ... existing configuration ...

#   # NEW: Inject the User Data script (Base64 encoded)
#   user_data = var.user_data_script != "" ? base64encode(var.user_data_script) : null
# }

main.tf (Inside the app_tier module block)

# module "app_tier" {
#   source = "./modules/compute"
  
#   # ... existing inputs ...

#   # NEW: Template the script with dynamic values
#   user_data_script = templatefile("${path.module}/app-tier-setup.sh", {
#     db_host     = module.database.db_endpoint
#     db_user     = var.db_username
#     db_password = var.db_password
#     db_name     = var.db_name
#   })
# }