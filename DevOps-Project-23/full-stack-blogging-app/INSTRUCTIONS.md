## Steps to Reproduce the Project

### 1. Clone the Repository
```bash
git clone https://github.com/ougabriel/full-stack-blogging-app.git
cd full-stack-blogging-app
```

### 2. Setup CI/CD Pipeline with Jenkins
- Install Jenkins using the provided script:
```bash
./ci-scripts/install_jenkins.sh 
```
- Configure Jenkins with plugins for Docker, SonarQube, Maven, and Kubernetes.

### 3. Set up Kubernetes (EKS)
- Deploy the EKS cluster using Terraform:
```bash
cd terraform
terraform init
terraform apply --auto-approve
```
- Apply Kubernetes manifests to deploy the application:
```bash
kubectl apply -f kubernetes/deployment.yml
```

### 4. Setup Monitoring with Prometheus and Grafana
- Install Prometheus and Grafana using the provided scripts:
```bash
./ci-scripts/install_blackbox.sh
./ci-scripts/install_prometheus.sh
```
- Access Grafana and Prometheus through the browser:
  - Grafana: `http://<your-server-ip>:3000`
  - Prometheus: `http://<your-server-ip>:9090`

## Key Pipeline Stages
1. Git Checkout: Pulls the latest code from GitHub.
2. Build & Analysis: Maven builds the app, SonarQube analyzes the code.
3. Vulnerability Scan: Trivy scans the Docker image for vulnerabilities.
4. Docker Build & Push: Builds a Docker image and pushes it to DockerHub.
5. Deploy to EKS: Deploys the app to the Kubernetes cluster.
6. Monitor: Monitors uptime and performance using Prometheus and Grafana.

## Project Highlights
- Full CI/CD Automation: Automates the entire software development lifecycle, from code commit to deployment.
- Real-Time Monitoring: Integrates a comprehensive monitoring system using Prometheus and Grafana to ensure the app's health.
- Security-Focused: Static code analysis via SonarQube and vulnerability scans via Trivy ensure high code quality and security.

This is the detailed manual. It includes the actual steps you took and the troubleshooting we went through, making it a highly realistic engineering document.

```markdown
# 📖 Step-by-Step Project Setup & Troubleshooting Guide

This document details the exact configuration and commands required to replicate this DevSecOps pipeline from scratch.

---

## ✅ Prerequisites
* AWS Account with programmatic access.
* Local Tools Installed: `terraform`, `kubectl`, `aws-cli`, `git`.
* Accounts on GitHub and DockerHub.

---

## 🔹 Phase 1: Infrastructure as Code (Terraform)
We use Terraform to provision the underlying AWS EKS Cluster.

1. **Configure AWS CLI:**
   ```bash
   aws configure
Provision Cluster:

Bash
cd EKS_Terraform
terraform init
terraform plan
terraform apply --auto-approve
(Note: This takes ~15-20 minutes to provision the EKS control plane and worker nodes).

Connect Local kubectl to Cluster:

Bash
aws eks --region eu-west-2 update-kubeconfig --name devopsshack-cluster
kubectl get nodes  # Verify nodes are in 'Ready' state
🔹 Phase 2: Jenkins & CI Configuration
Server Setup: Launch an Ubuntu EC2 instance. Install Jenkins, Java 17+, Docker, and Trivy.

Jenkins Plugins Needed: Pipeline Maven Integration, SonarQube Scanner, Docker Pipeline, Kubernetes CLI.

Credentials Setup in Jenkins:

docker: Username/Password for DockerHub.

sonar-token: Secret text for SonarQube authentication.

Nexus Authentication: Managed via Jenkins maven-settings.xml.

🔹 Phase 3: Kubernetes RBAC & Deployment
Jenkins requires a restricted Service Account to deploy applications to the cluster safely.

Create the Namespace and Apply RBAC:

Bash
kubectl create namespace webapps
kubectl apply -f full-stack-blogging-app/rbac/
Generate Long-Lived Service Account Token:

Bash
kubectl create token jenkins -n webapps --duration=8760h
Save this token in Jenkins Credentials as a Secret Text named k8s-token.

Retrieve EKS API Server URL:

Bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
Update the serverUrl parameter in the Jenkinsfile deploy stage with this address.

🔹 Phase 4: Monitoring (Prometheus & Grafana)
Server Setup: Launch a separate t2.medium EC2 instance. Open inbound ports 3000, 9090, and 9115.

Blackbox Exporter Setup (Port 9115): Configure blackbox.yml to use the http_2xx module for probing the application LoadBalancer URL.

Prometheus Setup (Port 9090): Update prometheus.yml to scrape targets from the Blackbox exporter.

Grafana Setup (Port 3000):

Add Prometheus as a Data Source.

Import Dashboard ID 7587 to visualize endpoint uptime and response metrics.

❓ Troubleshooting Guide
Throughout the build, you may encounter the following common issues:

1. Nexus Error: 401 Unauthorized during Deploy Stage
Symptom: The Jenkins pipeline fails when Maven tries to upload the .jar to Nexus.

Cause: The maven-settings.xml file in Jenkins contains default placeholder passwords instead of the actual Nexus admin password.

Fix: Go to Jenkins -> Manage Jenkins -> Managed Files -> Edit the Maven settings file and update the <server> tags with correct credentials.

2. Nexus Error: 400 Bad Request (Repository immutable)
Symptom: Maven deploy fails stating the .pom or .jar cannot be updated.

Cause: Attempting to redeploy an identical version number (e.g., 0.0.3) to a "Release" repository, which are immutable by default.

Fix: Log in to Nexus -> Repositories -> maven-releases -> Change the Deployment Policy from "Disable redeploy" to "Allow redeploy".

3. Grafana Dashboard shows "No Data" or is empty
Symptom: Data source is connected, but the imported Blackbox dashboard shows zero metrics.

Cause: The Prometheus job name in your prometheus.yml (e.g., job_name: 'blackbox') does not match the dashboard's expected variable filter.

Fix: Open the Grafana Dashboard settings ⚙️ -> Variables -> Job -> Remove or update the Regex to allow all names (e.g., .*), then select the correct job from the dashboard dropdown.

4. Jenkins Pipeline Fails at Kubernetes Deploy
Symptom: Unauthorized or Forbidden errors when running kubectl apply.

Cause: Mismatch between the Jenkins credential ID and the Jenkinsfile, or the Service Account token has expired.

Fix: Verify that the credentialsId in the withKubeCredentials block exactly matches the ID in Jenkins Global Credentials (k8s-token), and ensure the correct EKS Server URL is hardcoded or passed as a variable.