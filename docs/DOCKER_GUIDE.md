# Docker Guide

## Docker Basics for This Project

### Understanding Containers

A **container** is a lightweight, standalone, executable package that includes everything needed to run an application:
- Code
- Runtime
- System tools
- Libraries
- Settings

### Dockerfile Anatomy

Each service has a `Dockerfile` that defines how to build the container image.

#### Example: Auth Service Dockerfile

```dockerfile
# Build stage
FROM python:3.11-slim as builder
WORKDIR /app
COPY microservices/auth-service/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY microservices/auth-service/app.py .

ENV PATH=/root/.local/bin:$PATH
ENV FLASK_APP=app.py

EXPOSE 5001

CMD ["python", "app.py"]
```

**Key Concepts**:
- **Multi-stage build**: Reduces final image size by only including necessary files
- **FROM**: Base image
- **WORKDIR**: Working directory inside container
- **COPY**: Copy files from host to container
- **RUN**: Execute commands during build
- **ENV**: Set environment variables
- **EXPOSE**: Document which ports the container listens on
- **CMD**: Default command to run when container starts

## Docker Commands

### Building Images

```bash
# Build a single service
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .

# Build all services
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .
docker build -t user-service:latest -f microservices/user-service/Dockerfile .
docker build -t product-service:latest -f microservices/product-service/Dockerfile .
docker build -t frontend:latest -f frontend/Dockerfile .
```

### Running Containers

```bash
# Run a single container
docker run -p 5001:5001 auth-service:latest

# Run with environment variables
docker run -p 5001:5001 -e SECRET_KEY=my-secret auth-service:latest

# Run in background (detached)
docker run -d -p 5001:5001 auth-service:latest

# Run with volume mount
docker run -p 3000:3000 -v /Users/gauravb/Documents/code/frontend:/app/src frontend:latest
```

### Container Management

```bash
# List running containers
docker ps

# List all containers (running and stopped)
docker ps -a

# View container logs
docker logs <container_id>

# Follow logs in real-time
docker logs -f <container_id>

# Stop container
docker stop <container_id>

# Remove container
docker rm <container_id>

# Execute command in running container
docker exec -it <container_id> /bin/bash

# View resource usage
docker stats
```

## Docker Compose

### What is Docker Compose?

Docker Compose is a tool to define and run multi-container Docker applications using a YAML file.

### docker-compose.yml Structure

```yaml
version: '3.8'

services:
  # Service definition
  auth-service:
    build:
      context: .
      dockerfile: microservices/auth-service/Dockerfile
    container_name: auth-service
    ports:
      - "5001:5001"
    environment:
      - FLASK_ENV=development
      - SECRET_KEY=your-secret-key
    networks:
      - microservices-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  microservices-network:
    driver: bridge
```

### Docker Compose Commands

```bash
# Start all services (build if necessary)
docker-compose up

# Start in background
docker-compose up -d

# Start specific service
docker-compose up auth-service

# Build images without starting
docker-compose build

# View running services
docker-compose ps

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f auth-service

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Execute command in service container
docker-compose exec auth-service /bin/bash

# Restart service
docker-compose restart auth-service
```

## Setting Up Development Environment

### Step 1: Install Docker

**macOS**:
```bash
# Using Homebrew
brew install docker

# Or download Docker Desktop from https://www.docker.com/products/docker-desktop
```

**Windows**: Download Docker Desktop from https://www.docker.com/products/docker-desktop

**Linux**:
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### Step 2: Verify Installation

```bash
docker --version
docker-compose --version
docker run hello-world
```

### Step 3: Start the Project

```bash
# Navigate to project directory
cd /path/to/microservices-project

# Build and start all services
docker-compose up --build

# In another terminal, verify services
docker-compose ps

# Test services
curl http://localhost:5001/health
curl http://localhost:5002/health
curl http://localhost:5003/health
```

## Development Workflow

### 1. Making Changes to Services

```bash
# Edit service code (e.g., auth-service/app.py)
nano microservices/auth-service/app.py

# Restart the service (compose handles rebuilding)
docker-compose restart auth-service

# Or rebuild and restart
docker-compose up -d --build auth-service
```

### 2. Making Changes to Frontend

```bash
# For development with hot reload
cd frontend
npm install
npm run dev

# Or using Docker with volume mount for live coding
# Modify docker-compose.yml to include:
# volumes:
#   - ./frontend:/app/src
```

### 3. Debugging Containers

```bash
# View logs
docker-compose logs -f auth-service

# Execute shell in container
docker-compose exec auth-service /bin/bash

# Inspect container details
docker-compose ps auth-service
```

## Health Checks

Health checks are critical for orchestration. They determine if a container is healthy.

### Configure Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
  interval: 10s          # Check every 10 seconds
  timeout: 5s            # Wait max 5 seconds for response
  retries: 5             # Fail after 5 consecutive failures
  start_period: 10s      # Give container 10s to start
```

### Check Health Status

```bash
# View health status
docker ps

# Output shows (healthy), (unhealthy), or (starting)
```

## Networking in Docker

### Docker Networks

```bash
# List networks
docker network ls

# Inspect network
docker network inspect microservices-network

# Services can communicate by service name:
# auth-service -> http://auth-service:5001
```

### Port Mapping

- External port: `5001` (on host)
- Internal port: `5001` (inside container)
- Format: `"5001:5001"`

### DNS Resolution

Within Docker Compose network:
```bash
# From one service to another
curl http://auth-service:5001/health
```

## Image Optimization

### Multi-stage Builds

Reduces image size by using multiple FROM statements:

```dockerfile
# Build stage - includes build tools
FROM python:3.11 as builder
RUN pip install --user flask

# Runtime stage - minimal base image
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
```

### Compare Image Sizes

```bash
docker images
```

### Tips for Smaller Images

1. Use slim/alpine base images
2. Multi-stage builds
3. Remove build dependencies in final stage
4. Use `.dockerignore` to exclude unnecessary files
5. Minimize the number of layers

## Building for Production

### Tag Images for Registry

```bash
# Tag with Docker Hub username
docker tag auth-service:latest username/auth-service:1.0.0

# Tag with private registry
docker tag auth-service:latest myregistry.azurecr.io/auth-service:1.0.0

# Push to registry
docker push username/auth-service:1.0.0
```

### Docker Compose for Production

```yaml
services:
  auth-service:
    image: username/auth-service:1.0.0  # Use pre-built image
    # ... rest of config
```

## Troubleshooting Docker Issues

### Common Issues

#### Container exits immediately

```bash
# Check logs
docker logs <container_id>

# Run with interactive terminal to see errors
docker run -it -p 5001:5001 auth-service:latest
```

#### Port already in use

```bash
# Find process using port
lsof -i:5001

# Kill process
kill -9 <PID>

# Or use different port
docker run -p 5002:5001 auth-service:latest
```

#### Out of disk space

```bash
# Clean up Docker images and containers
docker system prune -a

# Remove only stopped containers
docker container prune
```

#### Image not found

```bash
# Rebuild image
docker-compose build --no-cache

# Or build specific service
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .
```

### Getting Help

```bash
# View Docker events in real-time
docker events

# Inspect container details
docker inspect <container_id>

# View resource usage
docker stats
```

## Security Best Practices

1. **Use non-root user** (not in this learning project, but important for production)
2. **Scan images for vulnerabilities**:
   ```bash
   docker scan auth-service:latest
   ```
3. **Use private registries** for sensitive images
4. **Never hardcode secrets** in Dockerfile
5. **Keep base images updated**
6. **Minimize layers** to reduce attack surface

## Practice Exercises

1. **Build an image for each service**
   ```bash
   docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .
   ```

2. **Run all services with docker-compose**
   ```bash
   docker-compose up
   ```

3. **Test service endpoints**
   ```bash
   curl http://localhost:5001/health
   ```

4. **View service logs**
   ```bash
   docker-compose logs -f auth-service
   ```

5. **Execute command in container**
   ```bash
   docker-compose exec auth-service env
   ```

---

**Next Steps**:
- [KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md) - Deploy to Kubernetes
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Troubleshoot Docker issues
