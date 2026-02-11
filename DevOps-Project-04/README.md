# Deploy Django Application on AWS using ECS and ECR

![AWS](https://imgur.com/wLMcRHS.jpg)

**This article will deploy a Django-based application onto AWS using ECS (Elastic Container Service) and ECR (Elastic Container Registry). We start by creating the docker image of our application and pushing it to ECR. After that, we create the instance and deploy the application on AWS using ECS. Next, we ensure the application is running correctly using Django’s built-in web server.**

## Prerequisite

* Django
* Background on Docker
* AWS Account
* Creativity is always a plus 😃

## Django Web Framework

***Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design. It is free and open-source, has a thriving and active community, great documentation, and many free and paid-for support options. It uses HTML/CSS/Javascript for the frontend and python for the backend.***

## What are Dockers and Containers?

# Django Deployment on AWS ECS & ECR

This project demonstrates a complete containerized deployment pipeline for a Django application on AWS. The application is Dockerized, stored in Amazon Elastic Container Registry (ECR), and orchestrated using Amazon Elastic Container Service (ECS) with EC2 instances.

## 🏗️ Architecture
* **Application:** Django Web Framework (Python 3.9)
* **Containerization:** Docker
* **Registry:** AWS ECR (Private Repository)
* **Orchestration:** AWS ECS (EC2 Launch Type)
* **Compute:** AWS EC2 (`t2.micro` - Free Tier)

## ✅ Prerequisites
* AWS Account
* AWS CLI (configured via `aws configure`)
* Docker Desktop (running)
* Visual Studio Code

---

## 🚀 Step-by-Step Deployment Guide

### Phase 1: Containerization
1.  **Dockerfile Creation:**
    Used the official `python:3.9` image. Configured the container to expose port `8000` and run the Django development server.
    ```dockerfile
    FROM python:3.9
    WORKDIR /usr/src/app
    COPY requirements.txt ./
    RUN pip install -r requirements.txt
    COPY . .
    EXPOSE 8000
    CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
    ```

2.  **Build & Test Locally:**
    ```bash
    docker build -t django-app:v1 .
    docker run -p 8000:8000 django-app:v1
    # Verified at http://localhost:8000/admin
    ```

### Phase 2: Push to AWS ECR
1.  **Create Repository:**
    ```bash
    aws ecr create-repository --repository-name django-app-repo --region us-east-1
    ```
2.  **Authenticate & Push:**
    ```bash
    # Login
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

    # Tag
    docker tag django-app:v1 <AWS_ACCOUNT_ID>[.dkr.ecr.us-east-1.amazonaws.com/django-app-repo:latest](https://.dkr.ecr.us-east-1.amazonaws.com/django-app-repo:latest)

    # Push
    docker push <AWS_ACCOUNT_ID>[.dkr.ecr.us-east-1.amazonaws.com/django-app-repo:latest](https://.dkr.ecr.us-east-1.amazonaws.com/django-app-repo:latest)
    ```

### Phase 3: ECS Cluster Setup (Manual "ClickOps")
1.  **Create Cluster:**
    * Service: **Amazon ECS** -> **Clusters**
    * Infrastructure: **EC2 Linux + Networking**
    * Instance Model: **On-Demand**
    * Instance Type: **t2.micro** (Free Tier)
    * Desired Capacity: **1** (Crucial to ensure the worker node starts)

2.  **Create Task Definition:**
    * Family Name: `django-task`
    * Launch Type: **EC2**
    * Network Mode: **Bridge**
    * **Memory Configuration (Critical Fix):**
        * Hard Limit: **256 MiB** (To fit within t2.micro's 1GB limit)
        * CPU: 256 Units (.25 vCPU)
    * Port Mapping: Host: `8000` -> Container: `8000`

3.  **Run Task:**
    * Launched the task using the **EC2 Launch Type**.
    * Verified status changed from `PENDING` to `RUNNING`.

### Phase 4: Network Security
1.  Located the running EC2 instance in the **EC2 Console**.
2.  Updated the **Security Group Inbound Rules**:
    * **Type:** Custom TCP
    * **Port:** 8000
    * **Source:** 0.0.0.0/0 (Anywhere)
3.  **Final Verification:** Accessed `http://<EC2-PUBLIC-IP>:8000/admin`.

---

## 🔮 Future Improvements (Roadmap to Terraform)
Currently, this infrastructure was provisioned manually via the AWS Console ("ClickOps"). The next phase of this project involves automating the entire stack using **Infrastructure as Code (IaC)** with **Terraform**.

### planned Terraform Modules:
1.  **VPC Module:** Automate the creation of a Virtual Private Cloud, Subnets, and Internet Gateway to isolate the network.
2.  **ECR Module:** Define the image repository purely in code.
3.  **ECS Module:**
    * Automate the Cluster creation.
    * Define the **Task Definition** (CPU/Memory) in HCL code to prevent manual configuration errors.
    * Set up an **ECS Service** to ensure the task auto-restarts if it crashes.
4.  **Security Groups:** Define ingress rules (Port 80/8000) strictly via code to track changes.

### Why Terraform?
* **Reproducibility:** Spin up the entire environment in minutes with `terraform apply`.
* **State Management:** Track the exact state of the infrastructure.
* **Disaster Recovery:** If the cluster is deleted, it can be restored immediately without remembering manual settings.