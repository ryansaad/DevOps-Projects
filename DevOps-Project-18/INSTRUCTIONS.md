# **References**

# **Now, lets get started and dig deeper into each of these steps :-**

**Step 1** — Launch an AWS T2 Large Instance. Use the image as Ubuntu. You can create a new key pair or use an existing one. Enable HTTP and HTTPS settings in the Security Group.

![](<https://miro.medium.com/v2/resize:fit:700/0*O7OTR8slamA50Wgr.png>)

**Step 2** — Install Jenkins, Docker and Trivy

**2A — To Install Jenkins**

Connect to your console, and enter these commands to Install Jenkins

```c
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

sudo apt update
sudo apt install openjdk-17-jdk
sudo apt install openjdk-17-jre

sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

Once Jenkins is installed, you will need to go to your AWS EC2 Security Group and open Inbound Port 8080, since Jenkins works on Port 8080.

![](<https://miro.medium.com/v2/resize:fit:700/0*LwcZZbzeA-C2wTqx.png>)

Now, grab your Public IP Address

```c
<EC2 Public IP Address:8080>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Unlock Jenkins using an administrative password and install the required plugins.

![](<https://miro.medium.com/v2/resize:fit:700/0*Kx6RTKAtbvrbb9xw.png>)

Jenkins will now get installed and install all the libraries.

![](<https://miro.medium.com/v2/resize:fit:700/0*1vBCl0k1egywfmUs.png>)

Jenkins Getting Started Screen

![](<https://miro.medium.com/v2/resize:fit:700/0*13LX3qVtgaKk2qMj.png>)

**2B — Install Docker**

```c
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock 
sudo docker ps
```

After the docker installation, we create a sonarqube container (Remember added 9000 port in the security group)

![](<https://miro.medium.com/v2/resize:fit:700/0*IpH7z19f_OwmC2LS.png>)

```c
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

![](<https://miro.medium.com/v2/resize:fit:700/0*8xbXhpkCePWV5y9e.png>)

![](<https://miro.medium.com/v2/resize:fit:700/0*XfaIUB3jOyoVszR-.png>)

![](<https://miro.medium.com/v2/resize:fit:700/0*yo4nGGCCWjo1RvxL.png>)

**2C — Install Trivy**

```c
sudo apt-get install wget apt-transport-https gnupg lsb-release

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt-get update

sudo apt-get install trivy -y
```

**Step 3** — Install Plugins like JDK, Sonarqube Scanner, OWASP Dependency Check,

Goto Manage Jenkins →Plugins → Available Plugins →

Install below plugins

1 → Eclipse Temurin Installer (Install without restart)

2 → SonarQube Scanner (Install without restart)

Goto Manage Jenkins →Plugins → Available Plugins →

![](<https://miro.medium.com/v2/resize:fit:700/0*cbVykPMNxn3tw_PU>)

**3B — Configure Java in Global Tool Configuration**

Goto Manage Jenkins → Tools → Install JDK17→ Click on Apply and Save

![](<https://miro.medium.com/v2/resize:fit:700/0*zYdw40z-5gw_42w->)

j

**Step 4** — GotoDashboard → Manage Jenkins → Plugins → OWASP Dependency-Check. Click on it and install without restart.

![](<https://miro.medium.com/v2/resize:fit:700/0*KAvm1lIo5q_Zabf_.png>)

First, we configured Plugin and next we have to configure Tool

Goto Dashboard → Manage Jenkins → Tools →

![](<https://miro.medium.com/v2/resize:fit:700/0*K8g-d8eTm0RUD_p-.png>)

Click on apply and Save here.

Grab the Public IP Address of your EC2 Instance, Sonarqube works on Port 9000, sp &lt;Public IP&gt;:9000. Goto your Sonarqube Server. Click on Administration → Security → Users → Click on Tokens and Update Token → Give it a name → and click on Generate Token

![](<https://miro.medium.com/v2/resize:fit:700/0*3gBiIjfApFZu3W_S>)

Click on Update Token

![](<https://miro.medium.com/v2/resize:fit:700/0*taDsfS0qRoAM_fiw>)

Create a token with a name and generate

![](<https://miro.medium.com/v2/resize:fit:700/0*uSmQWIn8kYsHd57g>)

Copy this Token

Goto Dashboard → Manage Jenkins → Credentials → Add Secret Text. It should look like this

![](<https://miro.medium.com/v2/resize:fit:700/0*DPe8Nn-x1TBse7xE>)

You will this page once you click on create

![](<https://miro.medium.com/v2/resize:fit:700/0*tA4eDhtMM5BMEx6s>)

Now, go to Dashboard → Manage Jenkins → Configure System

![](<https://miro.medium.com/v2/resize:fit:700/0*Pc0urDY37r558t9U>)

Click on Apply and Save

The Configure System option is used in Jenkins to configure different server

Global Tool Configuration is used to configure different tools that we install using Plugins

We will install a sonar scanner in the tools.

![](<https://miro.medium.com/v2/resize:fit:700/0*8Hkj-gN9py3coePT>)

In the Sonarqube Dashboard add a quality gate also

Administration → Configuration →Webhooks

![](<https://miro.medium.com/v2/resize:fit:700/0*eOjYv9PUXdHxfY4I>)

Click on Create

![](<https://miro.medium.com/v2/resize:fit:700/0*nVNNh0lKbGfC0mwF>)

Add details

```c
#in url section of quality gate
<http://jenkins-public-ip:8080>/sonarqube-webhook/
```

![](<https://miro.medium.com/v2/resize:fit:700/1*JMqx0BB33EMUfKUiGRBTFg.png>)

Click on Apply and Save here.

**Step 6** — Create a Pipeline Project in Jenkins using Declarative Pipeline

```c
pipeline {
    agent any
    tools {
        jdk 'jdk17'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout From Git') {
            steps {
                git branch: 'master', url: 'https://github.com/NotHarshhaa/DevOps-Projects/tree/master/DevOps-Project-24/DotNet-monitoring'
            }
        }
        stage("Sonarqube Analysis ") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Dotnet-Webapp \
                        -Dsonar.projectKey=Dotnet-Webapp"""
                }
            }
        }
        stage("quality gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
        stage("TRIVY File scan") {
            steps {
                sh "trivy fs . > trivy-fs_report.txt"
            }
        }
        stage("OWASP Dependency Check") {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
    }
}
```

Click on Build now, you will see the stage view like this

![](<https://miro.medium.com/v2/resize:fit:700/1*0FJjDR-Np_hLdiiC0UblkQ.png>)

You will see that in status, a graph will also be generated and Vulnerabilities

![](<https://miro.medium.com/v2/resize:fit:700/1*dREJwJgJf9xO5vsKTAV6rA.png>)

To see the report, you can go to Sonarqube Server and go to Projects.

![](<https://miro.medium.com/v2/resize:fit:700/1*SzPyG21DLWk-b8DvZJTuLg.png>)

**Step 7** — Install make package

```c
sudo apt install make
# to check version install or not
make -v
```

**Step 8** — Docker Image Build and Push

We need to install the Docker tool in our system, Goto Dashboard → Manage Plugins → Available plugins → Search for Docker and install these plugins

* `Docker`

* `Docker Commons`

* `Docker Pipeline`

* `Docker API`

* `docker-build-step`

and click on install without restart

![](<https://miro.medium.com/v2/resize:fit:700/0*85KxZfG4p9p_BQIa>)

Now, goto Dashboard → Manage Jenkins → Tools →

![](<https://miro.medium.com/v2/resize:fit:700/0*GIQZSKzfoSllosGE>)

Add DockerHub Username and Password under Global Credentials

![](<https://miro.medium.com/v2/resize:fit:700/1*QDg2NMlXXQDwFGCyFeMXbA.png>)

In the makefile, we already defined some conditions to build, tag and push images to dockerhub.

![](<https://miro.medium.com/v2/resize:fit:700/0*Wwaph1bpJ8A_Wcbt>)

that’s why we are using make image and make a push in the place of docker build -t and docker push

Add this stage to Pipeline Script

```c
stage("Docker Build & tag"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){   
                       sh "make image"
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image NotHarshhaa/dotnet-monitoring:latest > trivy.txt" 
            }
        }
        stage("Docker Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){   
                       sh "make push"
                    }
                }
            }
        }
```

When all stages in docker are successfully created then you will see the result You log in to Dockerhub, and you will see a new image is created

![](<https://miro.medium.com/v2/resize:fit:700/1*JMqx0BB33EMUfKUiGRBTFg.png>)

**Stage view**

![](<https://miro.medium.com/v2/resize:fit:700/0*FKlA-GM4lHtoGiZi>)

**Step 9** — Deploy the image using Docker

Add this stage to your pipeline syntax

```c
stage("Deploy to container"){
            steps{
                sh "docker run -d --name dotnet -p 5000:5000 NotHarshhaa/dotnet-monitoring:latest"
            } 
        }
```

You will see the Stage View like this,

![](<https://miro.medium.com/v2/resize:fit:700/0*zle0Gb2SQ0RL-293>)

(Add port 5000 to Security Group)

![](<https://miro.medium.com/v2/resize:fit:700/0*vQuoGgXR2lYKPXT8.png>)

And you can access your application on Port 5000. This is a Real World Application that has all Functional Tabs.

**Step 10** — Access the Real World Application

![](<https://miro.medium.com/v2/resize:fit:700/1*dIreZ5hxmGS4atXzxTvyGQ.png>)

![](<https://miro.medium.com/v2/resize:fit:700/1*KU_P-XkW7K5p5aoNVzhWGw.png>)

**Step 11** — Kubernetes Set Up

Take-Two Ubuntu 20.04 instances one for k8s master and the other one for worker.

Install Kubectl on Jenkins machine as well.

```c
sudo apt update
sudo apt install curl
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

## **Part 1 — — — — — Master Node — — — — — —**

```c
sudo su
hostname master
bash
clear
```

## **— — — — — Worker Node — — — — — —**

```c
sudo su
hostname worker
bash
clear
```

## **Part 2 — — — — — — Both Master & Node — — — — —**

```c
sudo apt-get update 

sudo apt-get install -y docker.io
sudo usermod –aG docker Ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo snap install kube-apiserver
```

## **Part 3 — — — — — — — — Master — — — — — — — -**

```c
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
# in case your in root exit from it and run below commands
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## **— — — — — Worker Node — — — — — —**

```c
sudo kubeadm join <master-node-ip>:<master-node-port> --token <token> --discovery-token-ca-cert-hash <hash>
```

Now, goto the Master Node

```c
cd .kube/
cat config
```

Copy the config file to Jenkins master or the local file manager and save it

![](<https://miro.medium.com/v2/resize:fit:700/1*VypNKtvIVQBOseQfXZTM3Q.png>)

copy it and save it in documents or another folder save it as secret-file.txt

Install Kubernetes Plugin, Once it’s installed successfully

goto manage Jenkins → manage credentials → Click on Jenkins global → add credentials

![](<https://miro.medium.com/v2/resize:fit:700/0*Q6TmsbXxwe0z-vAD>)

Install Kubernetes Plugin, Once it’s installed successfully

![](<https://miro.medium.com/v2/resize:fit:700/0*yVlpodOoM5rKje61>)

Goto manage Jenkins → manage credentials → Click on Jenkins global → add credentials

The final step to deploy on the Kubernetes cluster, add this stage to the pipeline.

```go
stage('Deploy to k8s'){
            steps{
                dir('K8S') {
                  withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                    sh 'kubectl apply -f deployment.yaml'    
                   }
                }   
            }
        }
```

Before starting a new build remove Old containers.

Output

```c
kubectl get svc
#copy service port 
<worker-ip:svc port>
```

![](<https://miro.medium.com/v2/resize:fit:700/1*dIreZ5hxmGS4atXzxTvyGQ.png>)

![](<https://miro.medium.com/v2/resize:fit:700/1*KU_P-XkW7K5p5aoNVzhWGw.png>)

**Step 12** — Terminate the AWS EC2 Instance

Lastly, do not forget to terminate the AWS EC2 Instance.

**The complete pipeline script**

```c
pipeline{
    agent any
    tools{
        jdk 'jdk17'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout From Git'){
            steps{
                git branch: 'master', url: 'https://github.com/NotHarshhaa/DevOps-Projects/tree/master/DevOps-Project-24/DotNet-monitoring'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Dotnet-Webapp \
                    -Dsonar.projectKey=Dotnet-Webapp '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
                }
            } 
        }
        stage("TRIVY File scan"){
            steps{
                sh "trivy fs . > trivy-fs_report.txt" 
            }
        }
        stage("OWASP Dependency Check"){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage("Docker Build & tag"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){   
                       sh "make image"
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image NotHarshhaa/dotnet-monitoring:latest > trivy.txt" 
            }
        }
        stage("Docker Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){   
                       sh "make push"
                    }
                }
            }
        }
        stage("Deploy to container"){
            steps{
                sh "docker run -d --name dotnet -p 5000:5000 writetoritika/dotnet-monitoring:latest"
            } 
        }
        stage('Deploy to k8s'){
            steps{
                dir('K8S') {
                  withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                    sh 'kubectl apply -f deployment.yaml'    
                   }
                }   
            }
        }
    }
}
```

---

