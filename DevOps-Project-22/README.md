# DevSecOps: OpenAI Chatbot UI Deployment in EKS with Jenkins and Terraform

![text](https://imgur.com/MdxoqmL.png)

## **Introduction:**

In today’s digital world, user engagement is key to the success of any application. Implementing DevSecOps practices is essential for ensuring security, reliability, and efficient deployment processes. In this project, we aim to implement DevSecOps for deploying an OpenAI Chatbot UI. We will use Kubernetes (EKS) for container orchestration, Jenkins for Continuous Integration/Continuous Deployment (CI/CD), and Docker for containerization.

**What is ChatBOT?**

ChatBOT is an AI-powered conversational agent trained on extensive human conversation data. It utilizes natural language processing techniques to understand user queries and provide human-like responses. By simulating natural language interactions, ChatBOT enhances user engagement and provides personalized assistance to users.

**Why ChatBOT?**

**1\. Personalized Interactions:** ChatBOT enables personalized interactions by understanding user queries and responding in a conversational manner, fostering engagement and satisfaction.  
  
**2\. 24/7 Availability:** Unlike human agents, ChatBOT is available 24/7, ensuring instant responses to user queries and delivering a seamless user experience round the clock.  
  
**3\. Scalability:** With ChatBOT deployed in our application, we can efficiently handle a large volume of user interactions, ensuring scalability as our user base expands.

**How We’re Deploying ChatBOT?**

**1\. Containerization with Docker:** We’re containerizing the ChatBOT application using Docker, which provides lightweight, portable, and isolated environments for running applications. Docker enables consistent deployment across different environments, simplifying the deployment process and ensuring consistency.

**2\. Orchestration with Kubernetes (EKS):** Kubernetes provides powerful orchestration capabilities for managing containerized applications at scale. We’re leveraging Amazon Elastic Kubernetes Service (EKS) to deploy and manage our Docker containers efficiently. EKS automates container deployment, scaling, and management, ensuring high availability and resilience.

**3\. CI/CD with Jenkins:** Jenkins serves as our CI/CD tool for automating the deployment pipeline. We’ve configured Jenkins to continuously integrate code changes, run automated tests, and deploy the ChatBOT application to EKS. By automating the deployment process, Jenkins accelerates the delivery of updates and enhancements, improving efficiency and reliability.

**4\. DevSecOps Practices:** Throughout the deployment pipeline, we’re integrating security practices into every stage to ensure the security of our ChatBOT application. This includes vulnerability scanning, code analysis, and security testing to identify and mitigate potential security threats early in the development lifecycle.

By implementing DevSecOps practices and leveraging modern technologies like Kubernetes, Docker, and Jenkins, we’re ensuring the secure, scalable, and efficient deployment of ChatBOT, enhancing user engagement and satisfaction.

# 🤖 End-to-End DevSecOps Chatbot Deployment

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red)
![Kubernetes](https://img.shields.io/badge/Kubernetes-AWS_EKS-blue)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Docker](https://img.shields.io/badge/Docker-Containerization-blue)
![Security](https://img.shields.io/badge/Security-Trivy_%7C_SonarQube-green)

## 📖 Overview
This project demonstrates a production-grade **DevSecOps pipeline** for deploying a NodeJS Chatbot application. It fully automates infrastructure provisioning on AWS using **Terraform** and handles secure application deployment using a multi-stage **Jenkins Pipeline**.

By decoupling Infrastructure creation from Application deployment, this architecture ensures high stability, fast iteration cycles, and secure continuous delivery.

## 🏗️ Architecture & Pipeline Strategy
The project follows a **2-Pipeline Strategy**:

1. **Infrastructure Pipeline (The Builder):** * Automates the creation of AWS VPCs, Subnets, and an EKS (Elastic Kubernetes Service) Cluster using Terraform.
   * State is securely locked and managed using AWS S3 and DynamoDB.
2. **Application Pipeline (The Deployer):** * Fetches source code from GitHub.
   * Runs static code analysis via SonarQube.
   * Builds and pushes the Docker container to Docker Hub.
   * Performs vulnerability scanning (Filesystem & Image) using Trivy.
   * Deploys the final image to the AWS EKS cluster.

## 🛠️ Tech Stack
* **Cloud Provider:** AWS (EC2, EKS, IAM, S3, DynamoDB)
* **Infrastructure as Code (IaC):** Terraform
* **CI/CD:** Jenkins (Groovy Declarative Pipelines)
* **Containerization:** Docker & Docker Hub
* **Orchestration:** Kubernetes (AWS EKS)
* **Security & Quality:** SonarQube (Static Analysis), Trivy (Vulnerability Scanning)
* **Application:** NodeJS (React/Express Chatbot UI)

## 🚀 Key Features
* **Automated Provisioning:** One-click EKS cluster creation and teardown.
* **Shift-Left Security:** Integrated Trivy scans and SonarQube Quality Gates fail the build if vulnerabilities are detected.
* **Zero-Downtime Deployment:** Kubernetes handles load balancing and rolling updates.
* **State Management:** Remote Terraform state management prevents configuration drift.
