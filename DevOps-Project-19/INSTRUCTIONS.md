# Step-by-Step Deployment Instructions

This guide walks through deploying the entire AWS EKS CI/CD pipeline from scratch.

## Prerequisites
* An active **AWS Account** with Administrator access.
* **Terraform** installed locally.
* **AWS CLI** installed and configured (`aws configure`).
* **Git** installed locally.

---

## Phase 1: Provision the Jenkins Server

We first need a server to host Jenkins, which will act as our CI/CD orchestrator.



1. **Create an AWS Key Pair:**
   * Go to the AWS Console (us-east-1) > EC2 > Key Pairs.
   * Create a key pair named `DevOpss` (Format: `.pem`).
2. **Clone the Repository:**
   ```bash
   git clone [https://github.com/YOUR_USERNAME/DevOps-Project-19.git](https://github.com/YOUR_USERNAME/DevOps-Project-19.git)
   cd DevOps-Project-19
Run Terraform for EC2:

Bash
cd jenkins_server/tf-aws-ec2
terraform init
terraform apply -var-file="variables/dev.tfvars" -auto-approve
Note the IP: Copy the ec2_public_ip output at the end of the apply process.

Phase 2: Configure Jenkins
Unlock Jenkins:

Open http://<EC2_PUBLIC_IP>:8080 in your browser.

SSH into your EC2 instance to retrieve the admin password:

Bash
ssh -i "path/to/DevOpss.pem" ec2-user@<EC2_PUBLIC_IP>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
Paste the password and select Install Suggested Plugins.

Install Required Plugins:

Go to Manage Jenkins > Plugins > Available Plugins.

Install: Pipeline: AWS Steps, Terraform, Docker Pipeline, Kubernetes CLI.

Add AWS Credentials to Jenkins:

Go to Manage Jenkins > Credentials > System > Global credentials > Add Credentials.

Add two Secret text credentials:

ID: AWS_ACCESS_KEY_ID (Secret: Your actual access key)

ID: AWS_SECRET_ACCESS_KEY (Secret: Your actual secret key)

Phase 3: Configure the EKS Infrastructure Code
Before Jenkins can build the cluster, update the variables to match your AWS account.

Update Account ID:

Edit tf-aws-eks/variables/dev.tfvars and update aws_account_id to your 12-digit AWS Account ID.

Update Remote State Bucket:

Edit tf-aws-eks/backend.tf and ensure the bucket name matches a globally unique S3 bucket in your account.

Grant Jenkins IAM Access:

Edit tf-aws-eks/eks.tf to explicitly grant your Jenkins IAM user EKS admin rights so it doesn't get an Unauthorized error:

Terraform
enable_cluster_creator_admin_permissions = false
access_entries = {
  jenkins_admin = {
    principal_arn = "arn:aws:iam::YOUR_ACCOUNT_ID:user/YOUR_IAM_USER"
    policy_associations = {
      admin = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = { type = "cluster" }
      }
    }
  }
}
Push to GitHub:

Bash
git add .
git commit -m "Configured AWS EKS variables and IAM access"
git push origin main
Phase 4: Run the CI/CD Pipeline
Create the Jenkins Job:

In Jenkins, click New Item > Name it EKS-Deploy-Pipeline > Select Pipeline.

Under Pipeline definition, select Pipeline script from SCM.

Select Git, paste your repository URL, and set the Script Path to Jenkinsfile.

Build the Pipeline:

Click Build Now.

The pipeline will pause at the Terraform Plan stage. Review the plan and click Proceed to authorize the cluster creation.

Note: EKS cluster creation takes roughly 15-20 minutes.

Phase 5: Verification
Once the pipeline reports SUCCESS, verify your application is live.

Fetch the Load Balancer URL:
Run this locally to check the Kubernetes services:

Bash
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
kubectl get svc -n eks-nginx-app
Access the App:
Copy the EXTERNAL-IP address (e.g., a1b2c...us-east-1.elb.amazonaws.com) and paste it into your browser. You should see the Nginx welcome page.

Cleanup / Teardown
To avoid unexpected AWS charges, destroy the infrastructure when finished.

⚠️ CRITICAL: Delete the Load Balancer First!
Because Kubernetes created an AWS Load Balancer outside of Terraform's state, Terraform will fail to delete the VPC if the Load Balancer still exists.

Go to AWS Console > EC2 > Load Balancers.

Select the Load Balancer created by Kubernetes and click Delete.

(Optional) Check EC2 > Network Interfaces and delete any lingering ENIs tied to the ELB.

Destroy EKS Cluster:

Bash
cd tf-aws-eks
terraform destroy -var-file="variables/dev.tfvars" -auto-approve
Destroy Jenkins Server:

Bash
cd jenkins_server/tf-aws-ec2
terraform destroy -var-file="variables/dev.tfvars" -auto-approve