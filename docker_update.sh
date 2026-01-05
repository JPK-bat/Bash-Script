#!/bin/bash
set -e  # Exit immediately if any command fails

# Login ECR Repository
echo "Logging into ECR Repository..."
aws ecr get-login-password --region "region_name" | docker login --username AWS --password-stdin "ecr_registary_name"
echo "ECR login successful."

# Define variables
IMAGE_NAME="ecr_registary_name/Image_name:latest"
DOCKERFILE="Dockerfile"
CLUSTER_NAME="cluster_name"
SERVICE_NAME="service_name"

# Step 1: Build the Docker image
echo "Building the Docker image..."
docker build -t $IMAGE_NAME . -f $DOCKERFILE
echo "Docker image built successfully."

# Wait for 3 seconds before pushing
echo "Waiting for 3 seconds before pushing the image..."
sleep 3

# Step 2: Push the Docker image to ECR
echo "Pushing the Docker image to ECR..."
docker push $IMAGE_NAME
echo "Docker image pushed successfully."

# Step 3: Update ECS service to use new image
echo "Updating ECS service to launch new tasks..."
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment > /dev/null 2>&1
echo "ECS service update initiated."

# Wait for ECS service to stabilize
echo "Waiting for the ECS service to stabilize..."
if aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME; then
    echo " ECS service is now stable."
else
    echo " ECS service did not stabilize within the timeout period."
    exit 1
fi

# Step 4: Clean up local Docker image
echo "Cleaning up local Docker images to save space..."
docker rmi -f $IMAGE_NAME || true
docker system prune -f --volumes || true
echo "Local Docker images cleaned up successfully."
