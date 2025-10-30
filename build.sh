#!/bin/bash
set -e

echo "=== Logging into AWS ECR ==="
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 623653226560.dkr.ecr.us-east-1.amazonaws.com/devconnector

echo "=== Building Docker image ==="
docker build -t devconnector .

echo "=== Tagging Docker image ==="
docker tag devconnector:latest 623653226560.dkr.ecr.us-east-1.amazonaws.com/devconnector:latest

echo "=== Pushing Docker image to ECR ==="
docker push 623653226560.dkr.ecr.us-east-1.amazonaws.com/devconnector:latest

echo "=== Docker image pushed successfully to ECR ==="
