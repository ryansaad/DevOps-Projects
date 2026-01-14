# DevOps Project 32: Real-Time CI/CD Pipeline for Java (Tomcat & Kubernetes)

This project demonstrates a complete End-to-End DevSecOps pipeline for a Java Spring Boot application (**PetClinic**). It automates infrastructure provisioning using Terraform, implements CI/CD with Jenkins, enforces code quality with SonarQube, and supports two deployment strategies: Legacy (Tomcat) and Modern (Kubernetes).

## 🏗️ Architecture

The pipeline performs the following automated steps:
1.  **SCM**: Pulls code from GitHub.
2.  **Build**: Compiles Java code using Maven.
3.  **Test & Scan**:
    * **SonarQube**: Static Code Analysis (Bugs, Vulnerabilities, Code Smells).
    * **OWASP Dependency Check**: Scans libraries for known CVEs.
4.  **Package**: Builds a Docker Image and pushes it to Docker Hub.
5.  **Deploy**:
    * **Scenario A**: Deploys the `.war` artifact to an **Apache Tomcat** server.
    * **Scenario B**: Deploys the Docker container to a **Kubernetes** cluster.

---

## 🛠️ Prerequisites

* **AWS Account** (Admin Access)
* **Terraform** installed locally.
* **AWS CLI** configured.
* **Docker Hub** Account.

---

## 🚀 Phase 1: Infrastructure Provisioning (Terraform)

Since the original repository lacked IaC, this project includes custom Terraform scripts to provision an EC2 instance (`t2.medium`) with Jenkins, Docker, and Java pre-installed.

### 1. Setup Terraform Files
Create a folder `Jenkins-Server-TF` and add the necessary `.tf` files.

**`main.tf`** (snippet):
```hcl
resource "aws_security_group" "jenkins_sg" {
  # Opens ports 22 (SSH), 8080 (Jenkins), 8083 (Tomcat), 9000 (SonarQube)
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 (us-east-1)
  instance_type = "t2.medium"             # Required for Jenkins + SonarQube
  key_name      = var.key_name
  user_data     = file("install_jenkins.sh")
}
2. Execution
Bash

cd Jenkins-Server-TF
terraform init
terraform apply -var="key_name=YOUR_EXISTING_KEY_PAIR"
Wait 5-10 minutes for the User Data script to complete installation.

⚙️ Phase 2: Configuration
1. Jenkins Initial Setup
Access Jenkins at http://<EC2-Public-IP>:8080.

Unlock Jenkins: sudo cat /var/lib/jenkins/secrets/initialAdminPassword

Plugins Installed:

Eclipse Temurin Installer (Java)

SonarQube Scanner

Docker, Docker Pipeline, Docker API

OWASP Dependency-Check

Tools Configured (Manage Jenkins -> Tools):

JDK: jdk21 (Aligned with System Java to prevent OOM errors)

Maven: maven3

SonarScanner: sonar-scanner

Dependency-Check: dependency-check

2. SonarQube Setup
Run SonarQube via Docker:

Bash

# Increase Virtual Memory for Elasticsearch
sudo sysctl -w vm.max_map_count=262144

# Run Container
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
Access at http://<EC2-Public-IP>:9000.

Generate a User Token and add it to Jenkins Credentials (Global -> Secret Text) with ID: sonarqube-token.

Configure Server in Jenkins (System -> SonarQube servers).

3. Docker Hub Setup
Add Docker Hub credentials to Jenkins (Global -> Username with password) with ID: docker-cred.

📦 Scenario 1: Deployment to Apache Tomcat
This scenario deploys the raw .war artifact directly to a Tomcat application server running on port 8083.

1. Tomcat Server Setup
We install Tomcat on the same EC2 instance but on a different port to avoid conflict with Jenkins.

Bash

# Install
cd /opt
sudo wget [https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz](https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz)
sudo tar -xvf apache-tomcat-9.0.65.tar.gz

# Configure Port to 8083 (server.xml)
# Create User (tomcat-users.xml)
# Allow Remote Access in context.xml (Manager & Host-Manager)
2. Permissions (Crucial Step)
Allow Jenkins to copy artifacts to the webapps folder without a password. sudo visudo:

Plaintext

jenkins ALL=(ALL) NOPASSWD: /bin/cp
3. Jenkins Pipeline
The Jenkinsfile executes the build and copy steps.

Key Command:

Groovy

sh "sudo cp ${WORKSPACE}/DevOps-Project-32/JavaApp-CICD/target/petclinic.war /opt/apache-tomcat-9.0.65/webapps/"
4. Access Application
URL: http://<EC2-Public-IP>:8083/petclinic

☸️ Scenario 2: Deployment to Kubernetes (K8s)
This scenario deploys the application as a scalable container using the Docker image created during the CI process.

1. Minikube Setup (On EC2)
Instead of a managed EKS cluster, we use Minikube for a cost-effective, local K8s environment.

Bash

# Install Kubectl & Minikube
curl -LO [https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64](https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64)
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --driver=docker --force
2. Manifest Configuration
Update the Kubernetes deployment file (deployment.yaml) to use the image built by Jenkins.

YAML

spec:
  containers:
  - name: petclinic
    image: <YOUR_DOCKERHUB_USERNAME>/petclinic:latest
    ports:
    - containerPort: 8080
3. Deployment
Apply the configuration to the cluster:

Bash

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
4. Access Application
Since Minikube runs inside Docker, we port-forward the service to expose it to the internet.

Bash

kubectl port-forward --address 0.0.0.0 service/petclinic-service 8085:80
URL: http://<EC2-Public-IP>:8085

🛡️ Troubleshooting & Tips
Java Version Mismatch: If Jenkins crashes with OutOfMemory or Logging ID errors, ensure Jenkins, System, and Tools are aligned to JDK 21.

Swap Memory: Added 2GB Swap memory to the EC2 instance to prevent crashes when running Jenkins + SonarQube + Docker simultaneously.

Bash

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile