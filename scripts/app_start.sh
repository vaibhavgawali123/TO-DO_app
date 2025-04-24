#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

export NVM_DIR="/root/.nvm" # Or /home/ec2-user/.nvm if using ec2-user
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

APP_DIR="/var/www/mern-todo-app"

# Navigate to the application directory where code was deployed
cd $APP_DIR

echo "Starting Node application from $APP_DIR..."

# Create .env file from AWS Parameter Store values
echo "Fetching environment variables from AWS Parameter Store..."

# Use parameter names EXACTLY as they appear in Parameter Store
MONGO_URI_PARAM="/mern-app/prod/mongodb-uri" # Corrected based on screenshot
GMAIL_USER_PARAM="/mern-todo-app/gmail-username" # Assuming this is correct, adjust if needed
GMAIL_PASS_PARAM="/mern-todo-app/gmail-password" # Assuming this is correct, adjust if needed
JWT_SECRET_PARAM="/mern-todo-app/jwt-secret"     # Assuming this is correct, adjust if needed
PORT_PARAM="/mern-todo-app/port"                 # Assuming this is correct, adjust if needed

# Fetch parameters - exit script if any fetch fails due to 'set -e'
MONGO_URI=$(aws ssm get-parameter --name "$MONGO_URI_PARAM" --with-decryption --query Parameter.Value --output text)
GMAIL_USERNAME=$(aws ssm get-parameter --name "$GMAIL_USER_PARAM" --with-decryption --query Parameter.Value --output text)
GMAIL_PASSWORD=$(aws ssm get-parameter --name "$GMAIL_PASS_PARAM" --with-decryption --query Parameter.Value --output text)
JWT_SECRET=$(aws ssm get-parameter --name "$JWT_SECRET_PARAM" --with-decryption --query Parameter.Value --output text)
PORT=$(aws ssm get-parameter --name "$PORT_PARAM" --query Parameter.Value --output text)

# Write to .env file
echo "Writing .env file..."
cat > .env << EOF
MONGO_URI=${MONGO_URI}
GMAIL_USERNAME=${GMAIL_USERNAME}
GMAIL_PASSWORD=${GMAIL_PASSWORD}
JWT_SECRET=${JWT_SECRET}
PORT=${PORT}
EOF

# Optional: Export variables for the current script execution context if needed by PM2 immediately
# export $(grep -v '^#' .env | xargs)

echo "Starting application with PM2..."
# Ensure PM2 uses the node version managed by NVM
PM2_PATH=$(find $NVM_DIR/versions/node -name pm2 | head -n 1) # Find pm2 executable within NVM path
NODE_PATH=$(which node) # Get the path to the current node executable

# Start the application. Assumes server.js is the entry point in APP_DIR.
# Remove --watch for production-like deployment unless needed.
$PM2_PATH start server.js --name "mern-todo-app" --env production --interpreter $NODE_PATH #--watch --ignore-watch="node_modules"

# Ensure PM2 restarts on server reboot
$PM2_PATH startup | bash # The output of startup needs to be executed
$PM2_PATH save

echo "Application started successfully."