#!/bin/bash
export NVM_DIR="/root/.nvm" # Or /home/ec2-user/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

APP_DIR="/var/www/mern-todo-app"
cd $APP_DIR

echo "Starting Node application..."

# Create .env file from AWS Parameter Store values
echo "Fetching environment variables from AWS Parameter Store..."

# Create a temporary .env file
touch .env

# Fetch secrets from Parameter Store
# Note: EC2 instance role must have permissions to access these parameters
aws ssm get-parameter --name "/mern-todo-app/mongo-uri" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/gmail-username" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/gmail-password" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/jwt-secret" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/port" --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp

# Format the .env file properly with variable names
echo "MONGO_URI=$(sed -n '1p' .env.temp)" > .env
echo "GMAIL_USERNAME=$(sed -n '2p' .env.temp)" >> .env
echo "GMAIL_PASSWORD=$(sed -n '3p' .env.temp)" >> .env
echo "JWT_SECRET=$(sed -n '4p' .env.temp)" >> .env
echo "PORT=$(sed -n '5p' .env.temp)" >> .env

# Remove the temporary file
rm .env.temp

# Verify that critical environment variables are set
if [ ! -s .env ]; then
  echo "FATAL ERROR: Failed to retrieve environment variables from Parameter Store."
  exit 1
fi

# Export variables to current shell session (for immediate use if needed)
export $(grep -v '^#' .env | xargs)

# Start application with PM2
echo "Starting application with PM2..."
pm2 start server.js --name mern-app

# Ensure PM2 restarts app on server reboot
pm2 startup
pm2 save

echo "Application started successfully."