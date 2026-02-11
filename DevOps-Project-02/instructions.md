# 📘 Step-by-Step Implementation Guide

This document provides detailed instructions to replicate the Multi-VPC Enterprise Architecture. It includes network setup, security configurations, compute deployment, and troubleshooting steps for common issues encountered during implementation.

---

## 📋 Prerequisites
* **AWS Account** (Free Tier recommended).
* **AWS CLI** installed and configured.
* **SSH Client** (Terminal, PowerShell, or PuTTY).
* **A Key Pair** (`.pem` file) created in the `us-east-1` region.

---

## 🏗️ Phase 1: Environment Setup (Golden AMI)
*Goal: Create a pre-configured Amazon Machine Image (AMI) with necessary dependencies to speed up auto-scaling.*

1.  **Launch a Temporary EC2 Instance:**
    * **OS:** Amazon Linux 2023.
    * **Network:** Default VPC (Public Subnet).
    * **Security Group:** Allow SSH (Port 22).

2.  **Install Dependencies:**
    SSH into the instance and run:
    ```bash
    sudo dnf update -y
    sudo dnf install httpd git amazon-cloudwatch-agent -y
    sudo systemctl enable httpd
    ```

3.  **Create the AMI:**
    * Select the instance > **Actions** > **Image and templates** > **Create image**.
    * **Name:** `DevOps-Project-Golden-AMI`.
    * **Wait** for the status to become `Available`.
    * **Terminate** the temporary instance.

---

## 🌐 Phase 2: Network Infrastructure
*Goal: Create two isolated networks (VPCs).*

### 1. VPC A (Management)
* **IPv4 CIDR:** `192.168.0.0/16`
* **Name:** `VPC-A-Bastion`
* **Subnets:**
    * `VPC-A-Pub-Subnet`: `192.168.1.0/24` (Public)

### 2. VPC B (Production)
* **IPv4 CIDR:** `172.32.0.0/16`
* **Name:** `VPC-B-Prod`
* **Subnets:**
    * `VPC-B-Pub-AZ1`: `172.32.1.0/24` (Public - for ALB/NAT)
    * `VPC-B-Pub-AZ2`: `172.32.2.0/24` (Public - for ALB/NAT)
    * `VPC-B-Priv-AZ1`: `172.32.3.0/24` (Private - for Apps)
    * `VPC-B-Priv-AZ2`: `172.32.4.0/24` (Private - for Apps)

### 3. Gateways
* **Internet Gateway (IGW):** Create and attach to **both** VPC A and VPC B.
* **NAT Gateway:**
    * Create in `VPC-B-Pub-AZ1`.
    * Allocate an **Elastic IP**.

---

## 🔗 Phase 3: Connectivity (Transit Gateway & Routing)
*Goal: Connect the two isolated VPCs securely.*

### 1. Transit Gateway (TGW)
* **Create TGW:** Name it `TGW-Main`.
* **Create Attachments:**
    * **Attachment A:** VPC A / Subnet `VPC-A-Pub-Subnet`.
    * **Attachment B:** VPC B / Subnets `VPC-B-Priv-AZ1`, `VPC-B-Priv-AZ2`.

### 2. Route Tables (RT)
Configure the "maps" for traffic flow.

* **VPC A Public RT:**
    * `0.0.0.0/0` → Internet Gateway (`igw-...`)
    * `172.32.0.0/16` → Transit Gateway (`tgw-...`)
* **VPC B Public RT:**
    * `0.0.0.0/0` → Internet Gateway (`igw-...`)
    * `192.168.0.0/16` → Transit Gateway (`tgw-...`)
* **VPC B Private RT:**
    * `0.0.0.0/0` → NAT Gateway (`nat-...`) (For secure updates)
    * `192.168.0.0/16` → Transit Gateway (`tgw-...`) (For Admin SSH access)

---

## 🔒 Phase 4: Security & IAM
*Goal: Principle of Least Privilege.*

### 1. IAM Role for EC2
Create a role named `DevOps-App-Server-Role` with a custom policy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::YOUR-BUCKET-NAME",
                "arn:aws:s3:::YOUR-BUCKET-NAME/*"
            ]
        }
    ]
}
2. Security Groups (SG)
SG-Bastion (VPC A): Allow SSH (22) from Your_IP.

SG-ALB (VPC B): Allow HTTP (80) from 0.0.0.0/0.

SG-App-Private (VPC B):

Allow HTTP (80) only from SG-ALB.

Allow SSH (22) only from 192.168.0.0/16 (VPC A CIDR).

🚀 Phase 5: Compute & Scaling
Goal: Auto-healing and Load Balancing.

1. Launch Template
AMI: DevOps-Project-Golden-AMI

Instance Type: t2.micro

Key Pair: Your key.

Network: Select SG-App-Private.

IAM Instance Profile: DevOps-App-Server-Role.

User Data:

Bash
#!/bin/bash
cd /var/www/html
aws s3 cp s3://YOUR-BUCKET-NAME/ . --recursive
systemctl restart httpd
2. Application Load Balancer (ALB)
Type: Internet-Facing.

VPC: VPC-B-Prod.

Subnets: Select both Public subnets.

Security Group: SG-ALB.

Target Group: Creates TG-App-ALB-HTTP (Port 80).

3. Auto Scaling Group (ASG)
Launch Template: Select the one created above.

VPC: VPC-B-Prod.

Subnets: Select both Private subnets.

Load Balancing: Attach to the ALB Target Group.

Capacity: Desired: 2, Min: 2, Max: 4.

🔧 Troubleshooting Guide (Crucial Lessons)
❌ Issue 1: Site Timeout / Connection Refused
Symptoms: The Load Balancer DNS name hangs and eventually times out.
Cause: We initially used a Network Load Balancer (NLB). NLBs preserve the client IP address. When the request hit the private server, the server tried to reply directly to the client's public IP via the NAT Gateway. The firewall saw an unsolicited response and dropped it (Asymmetric Routing).
Solution: Switched to an Application Load Balancer (ALB). ALBs act as a proxy, so the server replies to the ALB's internal IP, ensuring symmetric routing.

❌ Issue 2: 403 Forbidden Error
Symptoms: The site loaded, but showed a "Forbidden" or "Test Page" error. ALB Health Checks failed.
Diagnosis: SSH'd into the instance and found /var/www/html was empty.
Cause: The IAM Role allowed s3:GetObject (download file) but not s3:ListBucket (view folder). The command aws s3 cp --recursive requires listing the bucket first.
Solution: Updated the IAM Policy to include s3:ListBucket.

❌ Issue 3: SSH "Permission Denied" from Bastion
Symptoms: Successfully SSH'd into Bastion, but failed to jump to the Private App Server.
Cause: The private key (.pem file) resides on the local laptop, not the Bastion.
Solution: Used SSH Agent Forwarding (ssh -A) to pass the key credential through to the next hop safely.

🧹 Cleanup
To avoid AWS charges, delete resources in this order:

Auto Scaling Group (This terminates instances).

Load Balancer.

NAT Gateway (Wait for "Deleted" status).

Elastic IP (Release it).

Transit Gateway Attachments -> Transit Gateway.

VPC A and VPC B.