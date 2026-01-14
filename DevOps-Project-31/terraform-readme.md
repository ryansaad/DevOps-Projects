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