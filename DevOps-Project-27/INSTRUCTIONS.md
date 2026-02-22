# 🚀 Step-by-Step Setup Instructions

This guide covers everything required to build the infrastructure, configure the tools, and run the DevSecOps pipeline.

---

## Phase 1: AWS Infrastructure Setup

Create **three** EC2 instances running **Ubuntu 24.04 LTS**.

1. **Jenkins & SonarQube Server:** `t2.large` (or `t2.medium`). 
   * **Security Group:** Allow Custom TCP on ports `22`, `8090` (Jenkins), and `9000` (SonarQube).
2. **K8s Master Node:** `t2.medium` (Must have at least 2 vCPUs).
   * **Security Group:** Allow All Traffic (for lab purposes).
3. **K8s Worker Node:** `t2.medium` or `t2.micro`.
   * **Security Group:** Allow All Traffic (for lab purposes). *Ensure port range 30000-32767 is open to the internet to access the app later.*

---

## Phase 2: Jenkins Server Configuration

SSH into your **Jenkins-Server** and run the following commands:

### 1. Install Java & Jenkins
```bash
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc [https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key](https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key)
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" [https://pkg.jenkins.io/debian-stable](https://pkg.jenkins.io/debian-stable) binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y

# Change Jenkins port to 8090 to prevent conflicts
sudo sed -i 's/HTTP_PORT=8080/HTTP_PORT=8090/g' /lib/systemd/system/jenkins.service
sudo systemctl daemon-reload
sudo systemctl restart jenkins
2. Install Docker & Run SonarQube
Bash
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo chmod 777 /var/run/docker.sock

# Start SonarQube container
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
3. Install Trivy & Kubectl
Bash
# Install Trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - [https://aquasecurity.github.io/trivy-repo/deb/public.key](https://aquasecurity.github.io/trivy-repo/deb/public.key) | sudo apt-key add -
echo deb [https://aquasecurity.github.io/trivy-repo/deb](https://aquasecurity.github.io/trivy-repo/deb) $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Install Kubectl (Required for Jenkins CD Pipeline)
curl -fsSL [https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key](https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key) | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] [https://pkgs.k8s.io/core:/stable:/v1.29/deb/](https://pkgs.k8s.io/core:/stable:/v1.29/deb/) /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
Phase 3: Kubernetes Cluster Setup
SSH into BOTH the K8s-Master and K8s-Worker nodes and run this exact script as root:

Bash
sudo su -

# Disable Swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Configure Network Bridging
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# Install Docker & Containerd
apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Configure Containerd to use Systemd (Fixes Kubelet CrashLoopBackOff)
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd

# Install Kubeadm, Kubelet, Kubectl (v1.29)
curl -fsSL [https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key](https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key) | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] [https://pkgs.k8s.io/core:/stable:/v1.29/deb/](https://pkgs.k8s.io/core:/stable:/v1.29/deb/) /' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
Initialize the Master Node
On the K8s-Master ONLY, run:

Bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure local kubectl access
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel Network Plugin
kubectl apply -f [https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml](https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml)
Copy the kubeadm join command printed at the end of the initialization.

Join the Worker Node
On the K8s-Worker ONLY, run the join command you copied. Example:

Bash
sudo kubeadm join <MASTER-IP>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
Phase 4: Jenkins Pipeline Configuration
Access Jenkins: http://<Jenkins-IP>:8090

Install Plugins: Go to Manage Jenkins -> Plugins. Install:

Eclipse Temurin Installer

SonarQube Scanner

Docker Pipeline

Kubernetes CLI

Configure Tools: Go to Manage Jenkins -> Tools.

Add JDK 17.

Add Maven 3.6.x.

Add Credentials: Go to Manage Jenkins -> Credentials. Add the following:

github: Your GitHub username and password/token.

docker-cred: Your Docker Hub username and password.

sonar-token: Secret Text (Generate this inside your SonarQube dashboard).

k8s: Secret File. (Run cat ~/.kube/config on your K8s Master, save the output to a text file locally, and upload it here).

Phase 5: Create and Run Jobs
Create the CI Job:

Name: DevSecOps-CI

Type: Pipeline

Definition: Pipeline script from SCM (Select Git, provide repo URL, script path: Jenkinsfile).

Create the CD Job:

Name: DevSecOps-CD

Type: Pipeline

Definition: Pipeline script from SCM (Select Git, provide repo URL, script path: CDJenkinsfile).

Run the Build!
Click Build Now on the DevSecOps-CI job. It will automatically trigger the CD job upon completion.

Phase 6: Verify Deployment
Once the CD pipeline succeeds, go to your K8s-Master terminal and run:

Bash
kubectl get pods
kubectl get svc
Look for the NodePort assigned to your service (e.g., 30507).

Open your browser and navigate to:
http://<K8s-Worker-Public-IP>:<NodePort>