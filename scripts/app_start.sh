#!/bin/bash
set -e

APP_DIR="/var/www/mern-todo-app"
BACKEND_DIR="$APP_DIR/backend"

cd $APP_DIR

echo "Fetching env variables from AWS Parameter Store..."

MONGO_URI=$(aws ssm get-parameter --name "/mern-app/prod/mongodb-uri" --with-decryption --query Parameter.Value --output text)
GMAIL_USERNAME=$(aws ssm get-parameter --name "/mern-todo-app/gmail-username" --with-decryption --query Parameter.Value --output text)
GMAIL_PASSWORD=$(aws ssm get-parameter --name "/mern-todo-app/gmail-password" --with-decryption --query Parameter.Value --output text)
JWT_SECRET=$(aws ssm get-parameter --name "/mern-todo-app/jwt-secret" --with-decryption --query Parameter.Value --output text)
PORT=$(aws ssm get-parameter --name "/mern-todo-app/port" --query Parameter.Value --output text)

echo "Writing .env..."
cat > "$BACKEND_DIR/.env" << EOF
MONGO_URI=${MONGO_URI}
GMAIL_USERNAME=${GMAIL_USERNAME}
GMAIL_PASSWORD=${GMAIL_PASSWORD}
JWT_SECRET=${JWT_SECRET}
PORT=${PORT}
EOF

echo "Installing PM2 if not found..."
command -v pm2 >/dev/null 2>&1 || npm install -g pm2

echo "Starting app from backend/server.js..."
cd $BACKEND_DIR
pm2 start server.js --name "mern-todo-app"

pm2 startup | bash || true
pm2 save

echo "App started!"
