# DevOps Project: Real-Time CI/CD Pipeline for Java (Tomcat & Kubernetes)

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

