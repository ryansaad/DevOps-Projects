# AWS 3-Tier Web Application Architecture (Manual Implementation)

## 📖 Overview
This project demonstrates the manual implementation of a highly available, scalable, and secure **3-Tier Web Application Architecture** on AWS. 

Following the "ClickOps" methodology (console-based setup), this project segregates the application into three distinct layers to ensure separation of concerns and security:

1.  **Web Tier (Presentation):** Handles incoming user traffic via Nginx servers.
2.  **App Tier (Logic):** Processes business logic using a Node.js application.
3.  **Database Tier (Data):** Persists data using Amazon RDS (MySQL).

## 🏗 Architecture
The architecture is deployed across **2 Availability Zones (AZs)** for high availability and fault tolerance.

* **VPC:** A custom Virtual Private Cloud to host the network.
* **Public Subnets:** Host the NAT Gateways and External Load Balancer.
* **Private Subnets:** Host the Web Tier and Application Tier instances.
* **Protected Subnets:** Host the RDS Database (Data layer).
* **Load Balancing:** Uses an **Internet-Facing ALB** for the Web Tier and an **Internal ALB** for the App Tier.
* **Auto Scaling:** Both Web and App tiers are part of Auto Scaling Groups (ASG) to handle traffic spikes.

## 🛠 Prerequisites
* **AWS Account:** Active account with administrative access.
* **Domain Name (Optional):** For Route53 configuration (not covered in this specific runbook).
* **Source Code:** The application code (frontend and backend) must be available locally to upload to S3.
    * *Reference Repo:* `https://github.com/aws-samples/aws-three-tier-web-architecture-workshop`

## 🚀 Deployment Strategy
This project follows a "Golden Image" strategy:
1.  **Configure:** Launch a base EC2 instance and configure the software manually.
2.  **Snapshot:** Create an Amazon Machine Image (AMI) of the configured instance.
3.  **Scale:** Use Launch Templates and Auto Scaling Groups to deploy instances from that AMI.

## 📂 Repository Structure
* `INSTRUCTIONS.md`: Detailed step-by-step runbook for manual deployment.
* `/app-tier`: Source code for the Node.js backend.
* `/web-tier`: Nginx configuration and static assets.