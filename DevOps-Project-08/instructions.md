# 📝 Step-by-Step Deployment Guide

## Phase 1: Setup The Manager Node
1.  **Launch EC2:**
    * Name: `Mario-Manager`
    * OS: Ubuntu 22.04 / 24.04
    * Type: `t2.micro`
2.  **IAM Role:**
    * Create a role `EKS-Manager-Role` with `AdministratorAccess` (for learning purposes).
    * Attach this role to your EC2 instance via **Actions > Security > Modify IAM Role**.

## Phase 2: Install Tooling
Connect to your instance and run:

```bash
# Switch to root
sudo su

# Install Tools
apt update -y
apt install docker.io -y
apt install unzip -y

# Install Terraform
wget -O- [https://apt.releases.hashicorp.com/gpg](https://apt.releases.hashicorp.com/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] [https://apt.releases.hashicorp.com](https://apt.releases.hashicorp.com) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install terraform -y

# Install AWS CLI
curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
curl -LO "[https://dl.k8s.io/release/$(curl](https://dl.k8s.io/release/$(curl) -L -s [https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl](https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl)"
chmod +x kubectl
mv kubectl /usr/local/bin/



Phase 3: Build Infrastructure
Clone Repository:

Bash
git clone [https://github.com/NotHarshhaa/Deployment-of-super-Mario-on-Kubernetes-using-terraform.git](https://github.com/NotHarshhaa/Deployment-of-super-Mario-on-Kubernetes-using-terraform.git)
cd Deployment-of-super-Mario-on-Kubernetes-using-terraform/EKS-TF
Configure Backend:

Edit backend.tf.

Change bucket to your OWN unique S3 bucket name.

Crucial: Comment out or remove the dynamodb_table line to avoid locking errors.

Deploy:

Bash
terraform init
terraform plan
terraform apply --auto-approve
Connect to Cluster:

Bash
aws eks update-kubeconfig --name EKS_CLOUD --region us-east-1
Phase 4: Deploy Application
Navigate to manifest folder:

Bash
cd ..
Apply Manifests:

Bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
Access the Game:

Run kubectl get svc to get the Load Balancer URL.

Paste into browser.

🧹 Cleanup (Urgent)
To avoid AWS charges, destroy resources in this exact order:

kubectl delete service mario-service

kubectl delete deployment mario-deployment

cd EKS-TF && terraform destroy --auto-approve

Terminate the EC2 Manager instance.


---


# 🔧 Troubleshooting & Common Errors

### 1. Error: "Error acquiring the state lock: ResourceNotFoundException"
**Cause:** The `backend.tf` file requested a DynamoDB table for state locking that did not exist.
**Fix:** Open `backend.tf` and remove/comment out the line `dynamodb_table = "terraform-lock"`. Run `terraform init -reconfigure`.

### 2. Error: "failed to get shared config profile, default"
**Cause:** The `provider.tf` file had `profile = "default"` hardcoded, looking for local credentials files.
**Fix:** In `provider.tf`, delete the line `profile = "default"`. Terraform will then automatically use the IAM Role attached to the EC2 instance.

### 3. Issue: "Site can't be reached (Timeout)" on Load Balancer URL
**Cause:** Network Load Balancers (NLB) preserve the client IP. The Worker Node Security Groups did not allow traffic from the internet.
**Fix:**
1.  Go to EC2 Console -> Instances.
2.  Select a **Worker Node** (not the Manager).
3.  Edit its **Security Group**.
4.  Add Inbound Rule: `All TCP` from `0.0.0.0/0`.