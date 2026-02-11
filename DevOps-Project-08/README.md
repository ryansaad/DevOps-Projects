# 🎮 Deployment of Super Mario on Kubernetes using Terraform  

![Super Mario](https://imgur.com/rC4Qe8g.png)  

## 📌 Overview  

Super Mario is a game we all cherish, and in this project, we bring it to life on **AWS EKS (Elastic Kubernetes Service)** using **Terraform** for infrastructure automation. This deployment leverages **Kubernetes, AWS EC2, and Terraform** to ensure a seamless, scalable, and cloud-native gaming experience.  

### ✅ Key Features  

- **Automated Infrastructure Provisioning** – Using Terraform to deploy AWS resources  
- **Kubernetes Orchestration** – Running Super Mario on EKS for scalability  
- **Containerization** – Dockerized game deployment  
- **AWS EC2 & Load Balancing** – Ensuring high availability and performance  
- **GitOps Workflow** – Infrastructure as Code (IaC) with version control  

---

## 🏗️ Architecture
The infrastructure is built on AWS using a "Manager Node" pattern.



1.  **Manager Node:** An EC2 instance acts as the administrative jump host.
2.  **Terraform:** Run from the Manager Node to provision the EKS Cluster.
3.  **EKS Cluster:** A managed Kubernetes control plane with EC2 Worker Nodes.
4.  **Load Balancer:** An AWS Network Load Balancer (NLB) to expose the game to the public internet.

## 🛠️ Prerequisites
* AWS Account
* Basic knowledge of Linux & CLI
* Access to create IAM Roles

## 🚀 Quick Start
See [INSTRUCTIONS.md](INSTRUCTIONS.md) for the step-by-step deployment guide.


## 💻 Project Source Code  

🔗 **Explore the Code Repository**:  
[GitHub – Super Mario on Kubernetes](https://github.com/NotHarshhaa/Deployment-of-super-Mario-on-Kubernetes-using-terraform)  

---
