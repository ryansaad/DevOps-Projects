# Comprehensive Step-by-Step Guide

This guide will take you from a blank AWS account to a fully functioning GitOps pipeline. 

---

## Phase 1: Infrastructure Provisioning (AWS EC2)

1. Log in to your AWS Management Console.
2. Navigate to **EC2** and click **Launch Instance**.
3. **Name:** `DevOps-Factory-Server`
4. **AMI:** Ubuntu Server 22.04 LTS or 24.04 LTS.
5. **Instance Type:** `t2.medium` (Required. `t2.micro` will crash when running Jenkins + SonarQube + Minikube).
6. **Key Pair:** Create a new `.pem` key pair and download it.
7. **Network/Security Group:** Allow the following inbound traffic:
   - Port `22` (SSH)
   - Port `80` (HTTP)
   - Port `8080` (Jenkins)
   - Port `9000` (SonarQube)
   - Port `30000-32767` (Kubernetes NodePorts)
8. Click **Launch Instance**.

---

## Phase 2: Tool Installation

SSH into your new EC2 instance:
`ssh -i "your-key.pem" ubuntu@<EC2-PUBLIC-IP>`

### 1. Install Java (Prerequisite for Jenkins)
```bash
sudo apt update
sudo apt install openjdk-11-jre -y

Install Jenkins
Bash
curl -fsSL [https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key](https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key) | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  [https://pkg.jenkins.io/debian-stable](https://pkg.jenkins.io/debian-stable) binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
Access Jenkins at http://<EC2-PUBLIC-IP>:8080 and follow the initial setup.

3. Install Docker
Bash
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
Log out and log back into your SSH session for Docker permissions to apply.

4. Install & Start SonarQube
We will run SonarQube as a Docker container for simplicity.

Bash
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
Access SonarQube at http://<EC2-PUBLIC-IP>:9000 (Default login: admin/admin).

5. Install Kubernetes (Minikube) & Kubectl
Bash
curl -LO [https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64](https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64)
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --driver=docker

curl -LO "[https://dl.k8s.io/release/$(curl](https://dl.k8s.io/release/$(curl) -L -s [https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl](https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl)"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
6. Install Helm & Argo CD
Bash
# Install Helm
curl -fsSL -o get_helm.sh [https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3](https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3)
chmod 700 get_helm.sh
./get_helm.sh

# Install Argo CD into the cluster
kubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)

# Expose Argo CD to access the UI
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
Phase 3: Jenkins Configuration
Install Plugins: Go to Jenkins > Manage Jenkins > Plugins. Install:

Docker Pipeline

SonarQube Scanner

Add Credentials: Go to Manage Jenkins > Credentials > System > Global credentials.

GitHub: Add a Secret Text (your Personal Access Token). ID: github

DockerHub: Add Username with password. ID: docker-cred

SonarQube: Add a Secret Text (SonarQube Token generated from the SonarQube UI). ID: sonarqube

Configure Tools: Go to Manage Jenkins > Global Tool Configuration.

Add SonarQube servers and link the credential you just created. Name it exactly as referenced in your Jenkinsfile.

Phase 4: Create the Pipeline
In Jenkins, click New Item -> Pipeline -> Name it Spring-Boot-Pipeline.

Under the Pipeline section, choose Pipeline script from SCM.

Choose Git and paste your GitHub repository URL.

Specify the script path as spring-boot-app/Jenkinsfile.

Save.

Phase 5: Argo CD Setup
Get the Argo CD initial admin password:

Bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
Port-forward the Argo CD service to access the UI:

Bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0
(Access it at https://<EC2-PUBLIC-IP>:8080. Note: You will get an SSL warning, proceed anyway).

Log in with username admin and the password from step 1.

Click New App:

Application Name: spring-boot-app

Project: default

Sync Policy: Automatic

Repository URL: Your GitHub Repo URL.

Path: spring-boot-app-manifests

Cluster URL: https://kubernetes.default.svc

Namespace: default

Click Create.

Phase 6: Run and Verify
Trigger a build in Jenkins.

Watch the stages complete: Checkout -> Build -> SonarQube -> Docker Push -> Update GitHub.

Once Jenkins finishes, check your GitHub repo. The deployment.yml should now have a new image tag.

Open the Argo CD UI. It will detect the change in GitHub and automatically deploy the new pods to Kubernetes.

Verify your app is running:

Bash
kubectl get pods
kubectl get svc