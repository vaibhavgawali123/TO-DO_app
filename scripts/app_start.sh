#!/bin/bash
export NVM_DIR="/root/.nvm" # Or /home/ec2-user/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

APP_DIR="/var/www/mern-todo-app"
cd $APP_DIR

echo "Starting Node application..."

# --- IMPORTANT: Environment Variable Handling ---
# Option 1: Use AWS Systems Manager Parameter Store (Recommended for secrets)
# Ensure EC2 Role has ssm:GetParameter permissions
export MONGODB_URI=$(aws ssm get-parameter --name "/mern-app/prod/mongodb-uri" --with-decryption --query Parameter.Value --output text --region ${AWS::Region})
export PORT=8000 # Or get from Parameter Store

# Option 2: Hardcode (NOT RECOMMENDED for secrets, ok for PORT)

# Check if MONGODB_URI is set
if [ -z "$MONGODB_URI" ]; then
  echo "FATAL ERROR: MONGODB_URI is not set."
  exit 1
fi

# Start application with PM2
# The 'name' allows easy management (stop, restart, logs)
pm2 start server.js --name mern-app

# Optional: Ensure PM2 restarts app on server reboot
pm2 startup
pm2 save