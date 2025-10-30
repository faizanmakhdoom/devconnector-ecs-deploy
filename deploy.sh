#!/bin/bash
set -e

echo "=== Starting ECS Task Registration and Deployment ==="

echo "=== Registering ECS Task Definition ==="

aws ecs register-task-definition \
  --region us-east-1 \
  --cli-input-json '{
    "family": "devconnector-task",
    "requiresCompatibilities": ["EC2"],
    "networkMode": "bridge",
    "executionRoleArn": "arn:aws:iam::623653226560:role/ecsTaskExecutionRole",
    "containerDefinitions": [
      {
        "name": "devconnector",
        "image": "623653226560.dkr.ecr.us-east-1.amazonaws.com/devconnector:latest",
        "essential": true,
        "memory": 512,
        "cpu": 256,
        "portMappings": [
          {
            "containerPort": 5000,
            "hostPort": 5000,
            "protocol": "tcp"
          }
        ],
        "environment": [
          { "name": "NODE_ENV", "value": "production" },
          { "name": "JWT_SECRET", "value": "supersecretkey" },
          { "name": "MONGO_URI", "value": "mongodb://172.31.12.45:27017/devconnector" }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/devconnector",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
      }
    ]
  }'

echo "=== Task Definition Registered Successfully ==="

echo "=== Updating ECS Service to Use New Task Definition ==="

aws ecs update-service \
  --cluster devconnector-cluster \
  --service devconnector-service \
  --force-new-deployment \
  --region us-east-1

echo "=== ECS Service Updated Successfully ==="
echo "=== Deployment Completed Successfully ==="
