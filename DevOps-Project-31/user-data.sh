#!/bin/bash
# app-tier-setup.sh

# 1. Capture the inputs passed from Terraform
# We use the templatefile function in Terraform to replace these placeholders
DB_HOST="${db_host}"
DB_USER="${db_user}"
DB_PASS="${db_password}"
DB_NAME="${db_name}"

# 2. Navigate to the application directory
# Adjust this path to where your code lives on the AMI
cd /home/ec2-user/app-tier

# 3. Create/Overwrite the Environment File
# This example creates a .env file, which is standard for Node.js apps
cat <<EOT > .env
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_NAME=$DB_NAME
PORT=4000
EOT

# 4. Restart the Application
# Using PM2 (Process Manager) to restart the app so it picks up the new config
# Ensure PM2 is already installed on your AMI
pm2 restart all || pm2 start index.js --name "app-tier"

echo "App Tier Configuration Complete!"