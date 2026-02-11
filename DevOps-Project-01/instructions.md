# ⚙️ Step-by-Step Deployment Guide & Troubleshooting

This document details the exact commands and steps taken to deploy the Java 3-Tier Application.

---

## 🔹 Phase 1: Infrastructure Setup (AWS)

1. **Create 3 EC2 Instances (Ubuntu 22.04 or Amazon Linux 2):**
    * **Instance 1 (Database):** `t2.micro` | Tag: `db-server`
    * **Instance 2 (App):** `t2.micro` | Tag: `app-server`
    * **Instance 3 (Web):** `t2.micro` | Tag: `web-server`

2. **Configure Security Groups (Firewalls):**
    * **DB SG:** Allow port `3306` ONLY from `app-server` Private IP. Allow `22` (SSH) from your IP.
    * **App SG:** Allow port `8080` ONLY from `web-server` Private IP. Allow `22` (SSH) from your IP.
    * **Web SG:** Allow port `80` (HTTP) from `0.0.0.0/0` (Anywhere). Allow `22` (SSH) from your IP.

---

## 🔹 Phase 2: Database Layer Setup (DB Server)

SSH into the **Database Instance**:
```bash
ssh -i "your-key.pem" ubuntu@<DB-PUBLIC-IP>
1. Install MariaDB/MySQL:

Bash
sudo apt update
sudo apt install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
2. Secure the Installation:

Bash
sudo mysql_secure_installation
# Answer 'Y' to remove anonymous users, disallow root login remotely, remove test db.
3. Create Database and User:

Bash
sudo mysql -u root -p
(Run the following SQL commands inside the MySQL shell)

SQL
CREATE DATABASE accountsdb;
CREATE USER 'admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON accountsdb.* TO 'admin'@'%';
FLUSH PRIVILEGES;
EXIT;
4. Enable Remote Connections:
By default, MySQL only listens on 127.0.0.1. We need it to listen on the private IP so the App server can connect.

Bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
Find line: bind-address = 127.0.0.1

Change to: bind-address = 0.0.0.0

Save (Ctrl+O, Enter) and Exit (Ctrl+X).

5. Restart Database:

Bash
sudo systemctl restart mariadb
🔹 Phase 3: Application Layer Setup (App Server)
SSH into the App Instance:

Bash
ssh -i "your-key.pem" ubuntu@<APP-PUBLIC-IP>
1. Install Java (JDK) and Maven:

Bash
sudo apt update
sudo apt install openjdk-11-jdk maven -y
# Verify installation
java -version
mvn -version
2. Clone the Source Code:

Bash
git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
cd your-repo-name
3. Update Database Configuration:
Edit the application properties file to point to your DB server.

Bash
nano src/main/resources/application.properties
Update jdbc.url: Replace localhost with the Private IP of your DB Server.

Update username and password if you changed them in Phase 2.

4. Build the Artifact (.jar or .war):

Bash
mvn clean package
5. Run the Application:

Bash
# Run in background using nohup
nohup java -jar target/accounts-0.0.1-SNAPSHOT.jar > app.log 2>&1 &
🔹 Phase 4: Presentation Layer Setup (Web Server)
SSH into the Web Instance:

Bash
ssh -i "your-key.pem" ubuntu@<WEB-PUBLIC-IP>
1. Install Nginx:

Bash
sudo apt update
sudo apt install nginx -y
2. Configure Nginx as a Reverse Proxy:
We need Nginx to forward traffic from Port 80 to our App Server on Port 8080.

Bash
sudo nano /etc/nginx/sites-available/default
Replace the location / block with:

Nginx
location / {
    proxy_pass http://<APP-SERVER-PRIVATE-IP>:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
3. Restart Nginx:

Bash
sudo systemctl restart nginx
🔧 Troubleshooting Guide
Issue 1: "Connection Refused" when App tries to connect to DB
Symptom: The Java app fails to start, logs show CommunicationsLinkException.

Fix A (Config): Ensure /etc/mysql/mariadb.conf.d/50-server.cnf has bind-address = 0.0.0.0.

Fix B (Security Groups): Go to AWS Console > Security Groups. Ensure the DB-SG allows Inbound Traffic on port 3306 from the App-SG (or the App Server's Private IP).

Issue 2: 502 Bad Gateway on Nginx
Symptom: Visiting the Web Server Public IP gives a "502 Bad Gateway" error.

Cause: Nginx cannot talk to the Tomcat/Java App.

Fix:

Check if Java is running on the App Server: ps -ef | grep java.

Check if App Security Group allows port 8080 from the Web Server.

Verify the IP address in /etc/nginx/sites-available/default is the correct Private IP of the App Server.

Issue 3: Maven Build Fails
Symptom: mvn clean package fails with compilation errors.

Fix:

Ensure you installed the JDK, not just the JRE: sudo apt install openjdk-11-jdk.

Check for memory issues. If using t2.micro, add a swap file or stop other services.

Issue 4: "Access Denied for user 'admin'@'172.x.x.x'"
Symptom: App connects to DB server but login fails.

Fix:

Log into MySQL on the DB server.

Run: GRANT ALL PRIVILEGES ON accountsdb.* TO 'admin'@'%';

Run: FLUSH PRIVILEGES;