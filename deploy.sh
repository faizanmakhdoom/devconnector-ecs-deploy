#!/bin/bash
set -e

echo ">>> Running DevConnector ECS Deployment Script"

# 🔧 Configuration (hardcoded)
AWS_REGION="us-east-1"
ECS_CLUSTER="devconnector"
SERVICE_NAME="devconnector-task-service"
TASK_DEFINITION_FAMILY="devconnector-task"

# === 🧱 Define ECS Task Definition JSON ===
NEW_TASK_DEF=$(cat <<'JSON'
{
  "family": "devconnector-task",
  "networkMode": "bridge",
  "requiresCompatibilities": ["EC2"],
  "containerDefinitions": [
    {
      "name": "devconnector-frontend",
      "image": "656194817844.dkr.ecr.us-east-1.amazonaws.com/devconnector-frontend:latest",
      "portMappings": [
        { "containerPort": 80, "hostPort": 3000 }
      ],
      "memoryReservation": 128,
      "essential": false,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/devconnector-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "latest"
        }
      }
    },
    {
      "name": "devconnector-backend",
      "image": "656194817844.dkr.ecr.us-east-1.amazonaws.com/devconnector-backend:latest",
      "portMappings": [
        { "containerPort": 5000, "hostPort": 5000 }
      ],
      "environment": [
        { "name": "PORT", "value": "5000" },
        { "name": "MONGO_URI", "value": "mongodb://172.31.7.82:27017/devcollab" }
        { "name": "JWT_SECRET", "value": "superSecretKey123" }
      ],
       "memoryReservation": 256,
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/devconnector-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "latest"
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
  --cli-input-json "$NEW_TASK_DEF" \
  --region "$AWS_REGION"

# === 🚀 Force ECS Service to use new Task Definition ===
echo ">>> Updating ECS Service to deploy new task..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$SERVICE_NAME" \
  --force-new-deployment \
  --region "$AWS_REGION"

echo "✅ Deployment completed successfully!"
