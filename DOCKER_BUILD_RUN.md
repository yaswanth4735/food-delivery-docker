# Docker Build and Run Commands for FOODimage

## Prerequisites
- Docker installed (version 20.10+)
- Docker Compose installed (version 1.29+)
- Maven 3.8.0+
- Java 17+

---

## Method 1: Manual Build and Run

### Step 1: Build the Docker Image

```bash
# Navigate to project directory
cd food-delivery-docker

# Build the Docker image named 'foodimage'
docker build -t foodimage:latest .

# Verify the image was created
docker images | grep foodimage
```

**Expected Output:**
```
REPOSITORY   TAG      IMAGE ID       CREATED         SIZE
foodimage    latest   abc123def456   2 minutes ago    850MB
```

---

### Step 2: Run the Container

```bash
# Run the FOODimage container
docker run -d \
  --name food_delivery_app \
  -p 8080:8080 \
  -e JAVA_OPTS="-Xmx512m -Xms256m" \
  foodimage:latest

# Verify container is running
docker ps | grep food_delivery_app
```

**Explanation of flags:**
- `-d` : Run in detached mode (background)
- `--name` : Assign container name
- `-p 8080:8080` : Map port 8080 (host) to 8080 (container)
- `-e` : Set environment variables (JVM memory)

---

### Step 3: Verify Application is Running

```bash
# Check container logs
docker logs -f food_delivery_app

# Access the application
curl http://localhost:8080

# Or open in browser
# http://localhost:8080
```

---

### Step 4: Manage Container

```bash
# Stop the container
docker stop food_delivery_app

# Start a stopped container
docker start food_delivery_app

# Remove the container
docker rm food_delivery_app

# View container statistics
docker stats food_delivery_app

# Execute command inside container
docker exec -it food_delivery_app /bin/bash
```

---

## Method 2: Using Docker Compose (Recommended)

### Step 1: Start Services with Docker Compose

```bash
# Navigate to project directory
cd food-delivery-docker

# Build and start all services (app + database)
docker-compose up -d

# Verify services are running
docker-compose ps
```

**Expected Output:**
```
NAME                     COMMAND                  STATE           PORTS
food_delivery_db         docker-entrypoint.sh...  Up (healthy)   3306/tcp
food_delivery_app        catalina.sh run          Up (healthy)   0.0.0.0:8080->8080/tcp
```

---

### Step 2: Access the Application

```bash
# Application URL
curl http://localhost:8080

# Database connection
# Host: localhost
# Port: 3306
# Username: fooduser
# Password: foodpass123
# Database: food_delivery
```

---

### Step 3: Monitor and Manage Services

```bash
# View logs from all services
docker-compose logs -f

# View logs from specific service
docker-compose logs -f app

# Check service health
docker-compose ps

# Stop services
docker-compose stop

# Start services
docker-compose start

# Restart services
docker-compose restart

# Stop and remove containers, networks
docker-compose down

# Stop and remove everything including volumes
docker-compose down -v
```

---

## Method 3: Using Build Script (Automated)

```bash
# Make script executable
chmod +x build-and-run.sh

# Run the automated build and deployment script
./build-and-run.sh
```

This script will:
1. ✓ Run `mvn clean package`
2. ✓ Check Docker installation
3. ✓ Build Docker image
4. ✓ Clean up old containers
5. ✓ Run new container
6. ✓ Display access information

---

## Dockerfile Explanation

```dockerfile
# Stage 1: Build Stage
FROM maven:3.9.0-eclipse-temurin-17 AS builder
# - Uses Maven 3.9.0 with Java 17
# - Compiles Maven project
# - Generates WAR file

# Stage 2: Runtime Stage
FROM tomcat:10.1-jre17
# - Uses Tomcat 10.1 with Java 17
# - Removes default applications
# - Copies WAR file from builder
# - Exposes port 8080
# - Includes health checks
```

---

## Docker Image Statistics

| Aspect | Details |
|--------|---------|
| **Base Image** | tomcat:10.1-jre17 |
| **Build Time** | ~3-5 minutes (first build) |
| **Image Size** | ~850MB |
| **Port** | 8080 |
| **Health Check** | Every 30 seconds |

---

## Troubleshooting

### Issue: Port 8080 already in use

```bash
# Find process using port 8080
lsof -i :8080

# Or use different port
docker run -d -p 8081:8080 foodimage:latest
```

### Issue: Container exits immediately

```bash
# Check logs
docker logs food_delivery_app

# Rebuild without cache
docker build --no-cache -t foodimage:latest .
```

### Issue: Database connection failed

```bash
# Ensure database is running
docker-compose ps

# Check database logs
docker-compose logs db

# Restart database
docker-compose restart db
```

### Issue: Memory issues

```bash
# Increase JVM memory
docker run -d \
  -e JAVA_OPTS="-Xmx1024m -Xms512m" \
  -p 8080:8080 \
  foodimage:latest
```

---

## Performance Optimization

### Reduce Image Size

```dockerfile
# Use Alpine base image (smaller)
FROM tomcat:10.1-jre17-alpine
```

### Multi-stage Build Benefits
- ✓ Separates build dependencies from runtime
- ✓ Reduces final image size
- ✓ Improves security (build tools not in runtime)
- ✓ Faster deployments

---

## Docker Registry (Push to Docker Hub)

```bash
# Login to Docker Hub
docker login

# Tag image
docker tag foodimage:latest username/foodimage:latest

# Push image
docker push username/foodimage:latest

# Pull from registry
docker pull username/foodimage:latest
```

---

## Kubernetes Deployment (Optional)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: food-delivery-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: food-delivery
  template:
    metadata:
      labels:
        app: food-delivery
    spec:
      containers:
      - name: app
        image: foodimage:latest
        ports:
        - containerPort: 8080
        env:
        - name: JAVA_OPTS
          value: "-Xmx512m -Xms256m"
```

---

## Summary Commands

```bash
# Quick start with Docker Compose
docker-compose up -d

# Access application
curl http://localhost:8080

# View logs
docker-compose logs -f app

# Stop all services
docker-compose down

# Clean everything
docker-compose down -v
docker rmi foodimage:latest
```
