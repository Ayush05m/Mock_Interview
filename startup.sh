#!/bin/bash
set -e

# Update and install dependencies
apt-get update
apt-get install -y docker.io docker-compose nginx certbot python3-certbot-nginx

# Ensure project files are in place (assumes files are copied or pulled)
mkdir -p /app
mkdir -p /var/www/html
# Note: Copy your project files to /app (e.g., via SCP, Git, or GCP bucket)

# Set up Docker Compose
cd /app
docker-compose up -d

# Configure Nginx
cp /app/nginx/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx

# Obtain SSL certificate
certbot --nginx -d api.example.com --non-interactive --agree-tos --email your-email@example.com \
    --webroot-path /var/www/html