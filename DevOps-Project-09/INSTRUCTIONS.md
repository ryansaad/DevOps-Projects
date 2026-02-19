Technical Step-by-Step Guide: Zomato DevSecOps
Step 1: Infrastructure Setup
Launch Instance: Launch an AWS EC2 T2.Large instance (Ubuntu 22.04).

Security Group: Open the following inbound ports:

8080: Jenkins

9000: SonarQube

3000: React Application (Zomato Clone)

22: SSH (for access)

Step 2: Tool Installation
Run the following commands to install the core engine:

Bash
# Install Jenkins & Java 17
chmod +x scripts/jenkins.sh && ./scripts/jenkins.sh

# Install Docker
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER && newgrp docker
sudo chmod 777 /var/run/docker.sock

# Run SonarQube as a Container
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Install Trivy
chmod +x scripts/trivy.sh && ./scripts/trivy.sh
Step 3: Jenkins Configuration
Plugins to Install: Navigate to Manage Jenkins > Plugins and install:

Eclipse Temurin Installer

SonarQube Scanner

NodeJs Plugin

OWASP Dependency-Check

Docker Pipeline, Docker API, and docker-build-step

Global Tool Configuration: Navigate to Manage Jenkins > Tools:

JDK: Setup JDK 17 (Name: jdk17).

NodeJS: Setup NodeJS 16 (Name: node16).

Dependency Check: Add DP-Check.

Docker: Setup Docker (Name: docker).

Credentials: Navigate to Manage Jenkins > Credentials:

Sonar Token: Add as Secret Text (ID: Sonar-token).

DockerHub: Add as Username with Password (ID: docker).

Step 4: SonarQube Quality Gate
Create Token: In SonarQube (IP:9000), go to Security > Users > Tokens and generate a token.

Webhook: Go to Administration > Configuration > Webhooks.

Name: jenkins-webhook

URL: http://<YOUR_JENKINS_IP>:8080/sonarqube-webhook/

Step 5: Execute Pipeline
Create a New Item -> Pipeline project named Zomato-DevSecOps.

In the Pipeline Script section, copy and paste the Jenkinsfile content from this repository.

Ensure the Git URL in the script points to your GitHub fork.

Click Build Now.

Step 6: Verification & Cleanup
Access App: Once the pipeline succeeds, visit http://<EC2_PUBLIC_IP>:3000.

Security Reports: Check the Console Output and Dependency Check graph in Jenkins.

Terminate: To avoid AWS costs, terminate your EC2 instance once testing is complete.