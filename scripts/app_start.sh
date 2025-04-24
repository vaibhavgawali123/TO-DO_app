#!/bin/bash
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

APP_DIR="/var/www/mern-todo-app"
BACKEND_DIR="$APP_DIR/backend"

cd $BACKEND_DIR

echo "Starting Node application from $BACKEND_DIR..."

# Create .env file from AWS Parameter Store values
echo "Fetching environment variables from AWS Parameter Store..."

touch .env.temp

aws ssm get-parameter --name "/mern-todo-app/mongo-uri" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/gmail-username" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/gmail-password" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/jwt-secret" --with-decryption --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp
aws ssm get-parameter --name "/mern-todo-app/port" --query Parameter.Value --output text >> .env.temp && echo "" >> .env.temp

echo "MONGO_URI=$(sed -n '1p' .env.temp)" > .env
echo "GMAIL_USERNAME=$(sed -n '2p' .env.temp)" >> .env
echo "GMAIL_PASSWORD=$(sed -n '3p' .env.temp)" >> .env
echo "JWT_SECRET=$(sed -n '4p' .env.temp)" >> .env
echo "PORT=$(sed -n '5p' .env.temp)" >> .env

rm .env.temp

export $(grep -v '^#' .env | xargs)

echo "Starting application with PM2..."
pm2 start server.js --name "mern-todo-app" --watch --ignore-watch="node_modules" --env production --interpreter $(which node)

pm2 startup
pm2 save

echo "Application started successfully."
