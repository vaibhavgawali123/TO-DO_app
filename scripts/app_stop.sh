#!/bin/bash
export NVM_DIR="/root/.nvm" # Or /home/ec2-user/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Stopping Node application if running..."
# Gracefully stop the application using PM2
pm2 stop mern-app || true # || true prevents script failure if app not running
pm2 delete mern-app || true