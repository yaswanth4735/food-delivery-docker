#!/bin/bash
# Script to build and run FOODimage Docker container

set -e

IMAGE_NAME="foodimage"
IMAGE_TAG="latest"
CONTAINER_NAME="food_delivery_app"

echo "=========================================="
echo "Food Delivery Docker Build Script"
echo "=========================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Build Maven project
echo -e "${YELLOW}Step 1: Building Maven project...${NC}"
if [ ! -f "pom.xml" ]; then
    echo -e "${RED}Error: pom.xml not found!${NC}"
    exit 1
fi
mvn clean package -DskipTests
echo -e "${GREEN}Maven build completed!${NC}"

# Step 2: Check if Docker is installed
echo -e "${YELLOW}Step 2: Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed!${NC}"
    exit 1
fi
echo -e "${GREEN}Docker found!${NC}"

# Step 3: Build Docker image
echo -e "${YELLOW}Step 3: Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
echo -e "${GREEN}Docker image built successfully!${NC}"

# Step 4: Stop and remove existing container
echo -e "${YELLOW}Step 4: Cleaning up existing containers...${NC}"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container..."
    docker stop ${CONTAINER_NAME} || true
    docker rm ${CONTAINER_NAME} || true
    echo -e "${GREEN}Container cleaned up!${NC}"
fi

# Step 5: Run Docker container
echo -e "${YELLOW}Step 5: Running Docker container...${NC}"
docker run -d \
    --name ${CONTAINER_NAME} \
    -p 8080:8080 \
    -e JAVA_OPTS="-Xmx512m -Xms256m" \
    ${IMAGE_NAME}:${IMAGE_TAG}

echo -e "${GREEN}Container started successfully!${NC}"

# Step 6: Display container status
echo -e "${YELLOW}Step 6: Container Status${NC}"
docker ps --filter "name=${CONTAINER_NAME}"

echo ""
echo -e "${GREEN}=========================================="
echo "Build and Run Complete!"
echo "==========================================${NC}"
echo -e "Image Name: ${IMAGE_NAME}:${IMAGE_TAG}"
echo -e "Container Name: ${CONTAINER_NAME}"
echo -e "Access URL: http://localhost:8080"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs: docker logs -f ${CONTAINER_NAME}"
echo "  Stop container: docker stop ${CONTAINER_NAME}"
echo "  Remove image: docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
