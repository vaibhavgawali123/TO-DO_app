#!/bin/bash
export NVM_DIR="/root/.nvm" # Or /home/ec2-user/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

APP_DIR="/var/www/mern-todo-app"

# Create app directory if it doesn't exist
mkdir -p $APP_DIR

# Clean previous deployment (optional: be careful in production)
# rm -rf $APP_DIR/*

# (Optional) Install dependencies if not bundled in artifact by CodeBuild
# cd $APP_DIR
# npm install --production