#!/bin/bash
set -e

echo "=== Starting ECS Task Registration and Deployment ==="

echo "=== Registering ECS Task Definition ==="

aws ecs register-task-definition \
  --region us-east-1 \
  --cli-input-json '{
  "family": "devconnector-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["EC2"],
  "executionRoleArn": "arn:aws:iam::623653226560:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "mongodb",
      "image": "mongo:6.0",
      "essential": false,
      "memory": 512,
      "portMappings": [
        { "containerPort": 27017, "hostPort": 27017 }
      ],
      "mountPoints": [
        {
          "sourceVolume": "mongo_data_volume",
          "containerPath": "/data/db"
        }
      ]
    },
    {
      "name": "devconnector",
      "image": "623653226560.dkr.ecr.us-east-1.amazonaws.com/devconnector:latest",
      "essential": true,
      "memory": 512,
      "portMappings": [
        { "containerPort": 5000, "hostPort": 5000 }
      ],
      "environment": [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "JWT_SECRET", "value": "supersecretkey" },
        { "name": "MONGO_URI", "value": "mongodb://mongodb:27017/devconnector" }
      ],
      "dependsOn": [
        {
          "containerName": "mongodb",
          "condition": "START"
        }
      ]
    }
  ],
  "volumes": [
    {
      "name": "mongo_data_volume",
      "host": {
        "sourcePath": "/var/lib/docker/volumes/mongo_data"
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
