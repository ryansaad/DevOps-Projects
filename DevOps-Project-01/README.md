# ☕ Project 1: Deploy Java Application on AWS 3-Tier Architecture

## 📖 Overview
This project demonstrates a manual deployment of a comprehensive **3-Tier Web Architecture** on AWS. It hosts a Java-based application connected to a Database, separated into distinct layers for security and scalability.

The goal was to understand the core components of cloud infrastructure (EC2, Security Groups, Networking) and the software stack (Java, Tomcat, MySQL, Nginx) before moving to automated tools like Terraform or Ansible.

## 🏗️ Architecture Design
The infrastructure is divided into three logical tiers:
1.  **Presentation Tier (Web Layer):** An Nginx Web Server acting as a Reverse Proxy to handle incoming user traffic and route it to the application.
2.  **Application Tier (Logic Layer):** A Tomcat/Java Application Server running the business logic and API.
3.  **Data Tier (Database Layer):** A MySQL/MariaDB database storing user and application data, secured behind the application layer.

## 🛠️ Tech Stack
* **Cloud Provider:** AWS (EC2, VPC, Security Groups, IAM)
* **OS:** Linux (Ubuntu/Amazon Linux)
* **Web Server:** Nginx
* **Application Runtime:** Java (OpenJDK 11/17)
* **Build Tool:** Maven
* **Database:** MySQL / MariaDB
* **Version Control:** Git

## 🔑 Key Features
* **Security:** Strict Security Group rules ensure the Database is only accessible from the App Tier, and the App Tier is only accessible from the Web Tier.
* **Scalability:** The architecture allows for independent scaling of web, app, or data layers.
* **Reverse Proxy:** Nginx handles SSL termination (optional) and efficient request routing.

## 🚀 Prerequisites
* AWS Account with valid credentials.
* Basic familiarity with Linux/Bash commands.
* SSH Client (Terminal, Putty, or VS Code).