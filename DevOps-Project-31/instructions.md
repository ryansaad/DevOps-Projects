# Manual Deployment Guide: AWS 3-Tier Architecture

## Phase 1: Setup & Artifacts
**Goal:** Prepare storage for application code and IAM roles for security.

1.  **S3 Bucket:**
    * Create a dedicated S3 bucket (e.g., `three-tier-app-artifacts-123`).
    * Upload your App Tier code and Web Tier code into separate folders in this bucket.
2.  **IAM Role (EC2 Instance Profile):**
    * Create a role named `ThreeTier-EC2-Role`.
    * **Permissions:** Attach `AmazonS3ReadOnlyAccess` and `AmazonSSMManagedInstanceCore` (for Session Manager access).

## Phase 2: Network Foundation (VPC)
**Goal:** Create a network with strict isolation boundaries.

1.  **VPC:** Create a custom VPC (CIDR example: `10.0.0.0/16`).
2.  **Subnets (Total 6):**
    * **Public (x2):** `10.0.1.0/24` (AZ-1), `10.0.2.0/24` (AZ-2)
    * **Private App (x2):** `10.0.3.0/24` (AZ-1), `10.0.4.0/24` (AZ-2)
    * **Private DB (x2):** `10.0.5.0/24` (AZ-1), `10.0.6.0/24` (AZ-2)
3.  **Internet Gateway (IGW):** Create and attach to the VPC.
4.  **NAT Gateways:**
    * Create **NAT Gateway 1** in Public Subnet 1.
    * Create **NAT Gateway 2** in Public Subnet 2.
5.  **Route Tables:**
    * **Public RT:** Add route `0.0.0.0/0` -> IGW. Associate with Public Subnets.
    * **Private RT 1:** Add route `0.0.0.0/0` -> NAT Gateway 1. Associate with Private Subnets in AZ 1.
    * **Private RT 2:** Add route `0.0.0.0/0` -> NAT Gateway 2. Associate with Private Subnets in AZ 2.

## Phase 3: Security Groups (The Firewall)
**Goal:** Implement "Chained Security Groups" for deep defense.

1.  **ALB-External-SG:** Allow Inbound HTTP (80) from `0.0.0.0/0`.
2.  **Web-Tier-SG:** Allow Inbound HTTP (80) **only** from `ALB-External-SG`.
3.  **ALB-Internal-SG:** Allow Inbound HTTP (80) **only** from `Web-Tier-SG`.
4.  **App-Tier-SG:** Allow Inbound Custom TCP (4000) **only** from `ALB-Internal-SG`.
5.  **DB-Tier-SG:** Allow Inbound MySQL (3306) **only** from `App-Tier-SG`.

## Phase 4: Database Tier
**Goal:** Deploy the persistent storage layer.

1.  **Subnet Group:** Create an RDS Subnet Group selecting the two **Private DB Subnets**.
2.  **RDS Instance:**
    * Engine: MySQL.
    * Template: Dev/Test (or Free Tier).
    * Network: Select created VPC and the **DB-Tier-SG**.
    * **Action:** Copy the "Writer Endpoint" once the DB is active.

## Phase 5: Application Tier (Backend)
**Goal:** Configure the backend logic and internal load balancing.

1.  **Launch Setup Instance:**
    * Launch an EC2 in the **Private App Subnet**.
    * Attach `ThreeTier-EC2-Role`.
    * Use Session Manager to connect.
2.  **Configuration:**
    * Install Node.js and MySQL tools.
    * Download code from your S3 bucket.
    * Update the database config file with the RDS Writer Endpoint.
    * Test the app locally (e.g., `pm2 start app.js`).
3.  **Create AMI:** Create an image of this instance named `App-Tier-AMI`.
4.  **Internal Load Balancer:**
    * Create a Target Group (Port 4000, `/health`).
    * Create an **Application Load Balancer (Internal Scheme)**.
    * Attach `ALB-Internal-SG`.
5.  **Auto Scaling:**
    * Create a Launch Template using `App-Tier-AMI`.
    * Create an Auto Scaling Group (Min: 2, Max: 2) attached to the Internal ALB.

## Phase 6: Web Tier (Frontend)
**Goal:** Configure the frontend proxy and public entry point.

1.  **Launch Setup Instance:**
    * Launch an EC2 in the **Public Subnet** (or Private if using SSM).
    * Attach `ThreeTier-EC2-Role`.
2.  **Configuration:**
    * Install Nginx.
    * Edit `nginx.conf`: Update the `proxy_pass` location to point to the **Internal ALB DNS Name**.
    * Download web assets from S3.
3.  **Create AMI:** Create an image of this instance named `Web-Tier-AMI`.
4.  **External Load Balancer:**
    * Create a Target Group (Port 80).
    * Create an **Application Load Balancer (Internet-Facing Scheme)**.
    * Attach `ALB-External-SG`.
5.  **Auto Scaling:**
    * Create a Launch Template using `Web-Tier-AMI`.
    * Create an Auto Scaling Group (Min: 2, Max: 2) attached to the External ALB.

## Phase 7: Verification
1.  Copy the **DNS Name** of the **External Load Balancer**.
2.  Paste it into a browser.
3.  Verify the UI loads and you can perform database transactions (Read/Write).