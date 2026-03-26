#!/bin/bash

# Quick start script for Docker Compose

set -e

echo "================================"
echo "Microservices Quick Start"
echo "================================"
echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✓ Docker found"
echo "✓ Docker Compose found"
echo ""

# Build images
echo "📦 Building Docker images..."
docker-compose build --no-cache

echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check if services are running
echo ""
echo "✓ Checking service health..."

services=("auth-service" "user-service" "product-service" "frontend")
for service in "${services[@]}"; do
    if docker-compose ps | grep -q "$service"; then
        echo "✓ $service is running"
    else
        echo "❌ $service failed to start"
    fi
done

echo ""
echo "✅ All services started!"
echo ""
echo "================================"
echo "Access your application:"
echo "================================"
echo "Frontend:         http://localhost:3000"
echo "Auth Service:     http://localhost:5001"
echo "User Service:     http://localhost:5002"
echo "Product Service:  http://localhost:5003"
echo ""
echo "Demo Credentials:"
echo "  Email:    user1@example.com"
echo "  Password: password123"
echo ""
echo "To stop services:"
echo "  docker-compose down"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f [service-name]"
echo ""
echo "To access service:"
echo "  curl http://localhost:5001/health"
echo ""
echo "================================"
