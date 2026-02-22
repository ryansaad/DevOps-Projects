# 🛡️ End-to-End DevSecOps Kubernetes Pipeline

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-blue)
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED)
![SonarQube](https://img.shields.io/badge/SonarQube-Security-orange)

## 📖 Project Overview
This project demonstrates a real-world, fully automated **DevSecOps CI/CD Pipeline**. It automates the process of building, testing, securing, and deploying a Java-based web application (JPetStore) to a self-managed **Kubernetes Cluster on AWS**.

By integrating tools like **SonarQube** and **Trivy**, this pipeline embraces a "Shift-Left" security methodology, ensuring code and container vulnerabilities are caught before they ever reach production.



## 🏗️ Pipeline Workflow

### **1. Continuous Integration (CI)**
* **Code Checkout:** Jenkins pulls the latest source code from GitHub.
* **Build:** Maven compiles the Java application and generates the artifact.
* **Static Application Security Testing (SAST):** SonarQube analyzes the source code for bugs, vulnerabilities, and code smells.
* **Software Composition Analysis (SCA):** Trivy scans the file system for hardcoded secrets and dependency vulnerabilities.
* **Containerization:** Docker builds the application into a container image.
* **Image Scanning:** Trivy scans the compiled Docker image for OS-level vulnerabilities (CVEs).
* **Push:** The secure Docker image is pushed to Docker Hub.

### **2. Continuous Deployment (CD)**
* **Trigger:** The CD pipeline is triggered automatically upon CI success.
* **Authentication:** Jenkins connects to the K8s Master node using a securely injected `kubeconfig`.
* **Deployment:** `kubectl` applies the `deployment.yaml` and `service.yaml` manifests.
* **Hosting:** The application runs on Kubernetes Worker nodes and is exposed via a NodePort.

## 🛠️ Technology Stack
| Category | Tool | Purpose |
| :--- | :--- | :--- |
| **Cloud Provider** | AWS (EC2) | Infrastructure hosting |
| **CI/CD** | Jenkins | Pipeline automation and orchestration |
| **Containerization** | Docker | Packaging the application |
| **Orchestration** | Kubernetes (Kubeadm) | Cluster management and deployment |
| **Security (SAST)** | SonarQube | Code quality and security analysis |
| **Security (SCA)** | Trivy | File system and container image vulnerability scanning |
| **Build Tool** | Maven | Java application compilation |

## 🚀 Getting Started
To replicate this project from scratch, please follow the detailed step-by-step guide in the [INSTRUCTIONS.md](./INSTRUCTIONS.md) file.