#!/bin/bash
set -e

echo ">>> Running DevConnector ECS Deployment Script"

# 🔧 Configuration (hardcoded)
AWS_REGION="us-east-1"
ECS_CLUSTER="devconnector"
SERVICE_NAME="devconnector-task-service"
TASK_DEFINITION_FAMILY="devconnector-task"


# === 🧱 Define ECS Task Definition JSON ===
NEW_TASK_DEFINITION=$(cat <<JSON
{
  "family": "devconnector-task",
  "networkMode": "bridge",
  "requiresCompatibilities": ["EC2"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "devconnector-frontend",
      "image": "623653226560.dkr.ecr.us-east-1.amazonaws.com/devconnector/frontend:latest",
      "memoryReservation": 256,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/devconnector-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "frontend"
        }
      }
    },
    {
      "name": "devconnector-backend",
      "image": "623653226560.dkr.ecr.us-east-1.amazonaws.com/devconnector/backend:latest",
      "memoryReservation": 512,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "environment": [
        { "name": "PORT", "value": "5000" },
        { "name": "MONGO_URI", "value": "mongodb://admin:admin123@54.234.64.158:27017/devconnector?authSource=admin" },
        { "name": "JWT_SECRET", "value": "superSecretKey123" }
      ],
      "essential": false,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/devconnector-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "backend"
        }
      }
    }
  ]
}
JSON
)

# === 🪣 Register the new Task Definition ===
echo ">>> Registering ECS Task Definition..."
aws ecs register-task-definition \
  --cli-input-json "$NEW_TASK_DEFINITION" \
  --region $AWS_REGION

# === 🚀 Force ECS Service to use new Task Definition ===
echo ">>> Updating ECS Service to deploy new task..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$SERVICE_NAME" \
  --force-new-deployment \
  --region "$AWS_REGION"

echo "✅ Deployment completed successfully!"
