# Implementation Guide: 3-Tier App on EKS

Follow these detailed steps to deploy the application from scratch.

## Prerequisites
* AWS CLI installed and configured (`aws configure`)
* `eksctl` installed
* `kubectl` installed
* `helm` installed
* A registered domain name (optional, for Route53 DNS mapping)

## Phase 1: Infrastructure Provisioning

### 1. Create the EKS Cluster
Deploy an EKS cluster with a managed node group.

```bash
eksctl create cluster \
  --name Akhilesh-cluster \
  --region eu-west-1 \
  --version 1.31 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed


  Update your local kubeconfig to interact with the new cluster:

Bash
export cluster_name=Akhilesh-cluster
aws eks update-kubeconfig --name $cluster_name --region eu-west-1
2. Prepare RDS Networking and Security
Extract the VPC ID created by EKS and create a private DB subnet group.

Bash
VPC_ID=$(aws eks describe-cluster --name Akhilesh-cluster --region eu-west-1 --query "cluster.resourcesVpcConfig.vpcId" --output text)

# Create Subnet Group (Replace subnet IDs with your private subnets)
aws rds create-db-subnet-group \
  --db-subnet-group-name akhilesh-postgres-private-subnet-group \
  --db-subnet-group-description "Private subnet group for PostgreSQL RDS" \
  --subnet-ids subnet-xxx subnet-yyy subnet-zzz \
  --region eu-west-1
Create a Security Group for RDS and allow traffic from the EKS nodes on port 5432:

Bash
aws ec2 create-security-group --group-name postgressg --description "SG for RDS" --vpc-id $VPC_ID --region eu-west-1

# Get SG IDs and authorize ingress
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=postgressg" "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text --region eu-west-1)
NODE_SG=$(aws eks describe-cluster --name Akhilesh-cluster --region eu-west-1 --query "cluster.resourcesVpcConfig.securityGroupIds[0]" --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 5432 --source-group $NODE_SG --region eu-west-1
3. Provision RDS Instance
Bash
aws rds create-db-instance \
  --db-instance-identifier akhilesh-postgres \
  --db-instance-class db.t3.small \
  --engine postgres \
  --engine-version 15 \
  --allocated-storage 20 \
  --master-username postgresadmin \
  --master-user-password YourStrongPassword123! \
  --db-subnet-group-name akhilesh-postgres-private-subnet-group \
  --vpc-security-group-ids $SG_ID \
  --no-publicly-accessible \
  --backup-retention-period 7 \
  --multi-az \
  --region eu-west-1
Phase 2: Kubernetes Configuration & Migrations
1. Create Namespace & Database Service
Create an isolated environment and an ExternalName service to abstract the RDS endpoint.

Bash
kubectl create namespace 3-tier-app-eks
# Apply the service using your specific RDS endpoint in the yaml
kubectl apply -f database-service.yaml
2. Apply Secrets and ConfigMaps
Base64 encode your database credentials and apply the configuration files.

Bash
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
3. Run Database Migrations
Run the Kubernetes Job to create tables and seed the initial data before starting the backend.

Bash
kubectl apply -f migration_job.yaml
# Verify completion
kubectl get jobs -n 3-tier-app-eks
Phase 3: Workload Deployment
Deploy the Flask backend and React frontend.

Bash
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml

# Verify pods are running
kubectl get pods -n 3-tier-app-eks
Phase 4: Ingress and ALB Controller
1. Configure OIDC and IAM for ALB Controller
Bash
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve

# Create IAM Policy and Service Account for the Load Balancer Controller
# (Requires downloading the iam_policy.json from AWS documentation)
eksctl create iamserviceaccount \
  --cluster=$cluster_name \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<YOUR_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
2. Install ALB Controller via Helm
Bash
helm repo add eks [https://aws.github.io/eks-charts](https://aws.github.io/eks-charts)
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$cluster_name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId=$VPC_ID \
  --set region=eu-west-1
3. Tag Subnets and Create Ingress
Ensure your public subnets are tagged with kubernetes.io/role/elb=1. Then apply the Ingress rules.

Bash
kubectl apply -f ingress.yaml
Verify the ALB was provisioned:

Bash
kubectl get ingress -n 3-tier-app-eks
4. Route 53 DNS Configuration (Optional)
Create an Alias (A) record in Route 53 pointing your custom domain to the newly created ALB DNS name.