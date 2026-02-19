# Zomato Clone: Secure DevSecOps Deployment 🚀

![DevSecOps](https://img.shields.io/badge/Focus-DevSecOps-red)
![Jenkins](https://img.shields.io/badge/CI%2FCD-Jenkins-orange)
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![Security](https://img.shields.io/badge/Security-Trivy%20%7C%20OWASP-green)

A comprehensive DevSecOps project demonstrating the secure, automated deployment of a React-based Zomato clone. This project integrates security at every stage of the CI/CD pipeline, ensuring that vulnerabilities are caught before the code ever hits production.



## 📌 Project Overview
The goal of this project is to move away from "standard" deployment and embrace **Shift-Left Security**. By integrating SonarQube, OWASP, and Trivy, we create a "Secure-by-Design" workflow.

### ✅ Key Features
* **Automated Pipeline:** Full Jenkins Declarative Pipeline.
* **Static Analysis (SAST):** Code quality and security checks via **SonarQube**.
* **Software Composition Analysis (SCA):** Identifying vulnerable dependencies using **OWASP Dependency Check**.
* **Container Security:** Image and Filesystem scanning using **Trivy**.
* **Immutable Infrastructure:** Containerized deployment using **Docker**.

## 🛠️ Tech Stack
* **Cloud:** AWS (EC2 T2.Large)
* **CI/CD:** Jenkins
* **Analysis:** SonarQube, OWASP Dependency Check, Trivy
* **Runtime:** Docker, Node.js (React)
* **Language:** Groovy (Jenkinsfile)

## 🏗️ Pipeline Architecture
The pipeline follows these rigorous stages:
1. **Workspace Cleanup** & **Git Checkout**
2. **SonarQube Analysis** (Code Quality Gate)
3. **Dependency Installation** (NPM)
4. **OWASP FS Scan** (Vulnerability reporting)
5. **Trivy FS Scan** (Filesystem security)
6. **Docker Build & Push** (Pushing to DockerHub)
7. **Trivy Image Scan** (Scanning the final artifact)
8. **Deployment** (Containerized execution)

## 🚀 Quick Start
1. Clone this repository.
2. Follow the detailed [INSTRUCTIONS.md](./INSTRUCTIONS.md) to set up your AWS environment.
3. Configure your Jenkins credentials for DockerHub and SonarQube.
4. Run the Pipeline!

---
