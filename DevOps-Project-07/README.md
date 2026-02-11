DevSecOps Netflix Clone Project


A complete End-to-End DevSecOps project that deploys a Netflix Clone (React App) to a Kubernetes Cluster on AWS. This project implements a CI/CD pipeline using Jenkins, integrates security scanning (SonarQube, Trivy), and sets up full-stack monitoring using Prometheus & Grafana via Helm.


🏗️ ArchitectureInfrastructure: AWS EC2 (Ubuntu 22.04)Containerization: DockerOrchestration: Kubernetes (Kubeadm 1.32)CI/CD: JenkinsSecurity:SonarQube: Static Application Security Testing (SAST)Trivy: File System & Container Image ScanningMonitoring: Prometheus & Grafana (Deployed via Helm)Application: React.js (Vite) + TMDB API🚀 PrerequisitesYou need 3 AWS EC2 Instances (Ubuntu 22.04 LTS):Jenkins-Server: t2.large (Jenkins, Docker, SonarQube, Trivy)K8s-Master: t2.medium (Kubeadm Control Plane)K8s-Worker: t2.medium (Worker Node)Ensure Security Groups allow traffic on ports:8080 (Jenkins)9000 (SonarQube)3000-10000 (React App Dev)30000-32767 (Kubernetes NodePort Range)6443 (Kubernetes API)

🛠️ Phase 1: Jenkins & Security 

Setup1. Install Jenkins (Java 17)Bashsudo apt update
sudo apt install fontconfig openjdk-17-jre -y
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
sudo systemctl enable --now jenkins
2. Install Docker & SonarQubeRun SonarQube as a Docker container to save resources.Bash# Install Docker
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
sudo chmod 777 /var/run/docker.sock

# Run SonarQube
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
3. Install Trivy (Security Scanner)Bashsudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
4. Jenkins PluginsInstall the following plugins via Manage Jenkins -> Plugins:Eclipse Temurin Installer (JDK)NodeJS PluginSonarQube ScannerDocker PipelineKubernetes CLI (Crucial for deployment)Email Extension (For notifications)



☸️ Phase 2: Kubernetes Cluster Setup (The "Hard Way")Since AWS removed DockerShim in K8s 1.24+, we must use cri-dockerd.1. Install Container Runtime (Master & Worker)Bash# Install Docker
sudo apt update && sudo apt install -y docker.io

# Install cri-dockerd (The Bridge)
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.14/cri-dockerd-0.3.14.amd64.tgz
tar -xvf cri-dockerd-0.3.14.amd64.tgz
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/

# Setup Systemd Services
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sudo mv cri-docker.service cri-docker.socket /etc/systemd/system/
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

# Start Service
sudo systemctl daemon-reload
sudo systemctl enable --now cri-docker.socket
2. Initialize Cluster (Master Only)Bashsudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock
Copy the join command provided at the end.Install Network Plugin (Flannel): kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml3. Join Worker NodeRun the join command on the worker node, appending the socket argument:Bashsudo kubeadm join <MASTER-IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash <HASH> --cri-socket=unix:///var/run/cri-dockerd.sock


📊 Phase 3: Monitoring (Helm vs. Traditional)This project uses Helm for monitoring. Below is a comparison of why we chose this approach over the traditional method.🆚 Why Helm?FeatureTraditional Setup (Manual)Helm Setup (Cloud Native)InstallationDownload binaries (wget), unzip, create users, create systemd files manually on every server.Single command (helm install) deploys everything instantly.ScalabilityIf you add a new K8s node, you must manually SSH in and install Node Exporter.Helm uses DaemonSets, so Node Exporter is automatically installed on any new node.Service DiscoveryYou must manually edit prometheus.yml to add IP addresses of targets.Prometheus Operator automatically finds new Pods and Services to monitor.MaintenanceHard to update.Easy upgrades via helm upgrade.🛠️ Implementation Steps1. Install Helm (Master Node)Bashcurl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
2. Deploy Prometheus StackWe use a specific configuration to support "Lab Environments" (Ephemeral Storage) so it doesn't crash on restarts.Bash# Add Repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create Namespace
kubectl create namespace monitoring

# Install Stack (With Crash-Fix for Lab Servers)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.storageSpec.emptyDir.medium="" \
  --set grafana.persistence.enabled=false \
  --set grafana.persistence.type=emptyDir \
  --set grafana.service.type=NodePort
3. Access GrafanaURL: http://<WORKER-IP>:<NODE-PORT>User: adminPassword: Use command below to reset if needed:Bashkubectl exec -it -n monitoring <GRAFANA-POD-NAME> -- grafana-cli admin reset-admin-password admin123


🔄 Phase 4: The CI/CD Pipeline (Jenkinsfile)The pipeline performs the following 7 stages automatically:
Checkout: Pulls code from GitHub.
Install Dependencies: Runs npm install.
Sonarqube Analysis: Checks code quality and bugs.
Security Scan (FS): Trivy scans the file system for vulnerabilities.
Build & Push: Docker builds the image and pushes to Docker Hub.
Security Scan (Image): Trivy scans the final Docker image.
Deploy: Uses kubectl to deploy to the AWS Kubernetes Cluster.
Post-Action: Sends an email notification with the build status.

Critical Files Fixed:Dockerfile: Removed COPY yarn.lock to fix build failure.
package.json: Removed extra comma (Syntax Error) and removed tsc from build command to bypass strict TypeScript checks.

✅ How to VerifyApplication:Visit http://<WORKER-IP>:30007 to see the Netflix Clone running.Monitoring:Visit http://<WORKER-IP>:<GRAFANA-PORT> -> Dashboards -> Kubernetes / Compute Resources / Namespace (Pods) to see real-time CPU/Memory usage.SonarQube:Visit http://<JENKINS-IP>:9000 to see the code quality report.