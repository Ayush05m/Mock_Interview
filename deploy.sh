#!/bin/bash
set -e

# Variables
PROJECT_ID="psyched-era-463605-g3"
VM_NAME="fastapi-microservice"
ZONE="asia=south1-a"
MACHINE_TYPE="e2-medium"
IMAGE_FAMILY="debian-11"
IMAGE_PROJECT="debian-cloud"
SUBDOMAIN="api.mentrax-ai.tech"
STARTUP_SCRIPT="startup.sh"

# Create VM
gcloud compute instances create $VM_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --tags=http-server,https-server \
    --metadata-from-file=startup-script=$STARTUP_SCRIPT

# Configure firewall rules
gcloud compute firewall-rules create allow-http-https \
    --project=$PROJECT_ID \
    --allow=tcp:80,tcp:443 \
    --target-tags=http-server,https-server \
    --description="Allow HTTP and HTTPS traffic"

# Reserve static IP
gcloud compute addresses create $VM_NAME-ip \
    --project=$PROJECT_ID \
    --region=${ZONE%-*}

# Attach static IP to VM
STATIC_IP=$(gcloud compute addresses describe $VM_NAME-ip --region=${ZONE%-*} --format="get(address)")
gcloud compute instances add-address $VM_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --address=$STATIC_IP

echo "Deployment started. VM: $VM_NAME, IP: $STATIC_IP"
echo "Update DNS A record for $SUBDOMAIN to point to $STATIC_IP"
echo "Copy project files to /app on the VM (e.g., via SCP or Git)"