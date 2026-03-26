#!/bin/bash

# Kubernetes quick deploy script

set -e

echo "================================"
echo "Kubernetes Quick Deploy"
echo "================================"
echo ""

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check minikube (optional)
if command -v minikube &> /dev/null; then
    echo "✓ Minikube found"
    
    # Start minikube if not running
    if ! minikube status | grep -q "Running"; then
        echo "🚀 Starting Minikube..."
        minikube start
    fi
    
    # Set docker env
    echo "🐳 Setting Docker environment..."
    eval $(minikube docker-env)
fi

echo ""
echo "📦 Building Docker images..."
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .
docker build -t user-service:latest -f microservices/user-service/Dockerfile .
docker build -t product-service:latest -f microservices/product-service/Dockerfile .
docker build -t frontend:latest -f frontend/Dockerfile .

echo ""
echo "📝 Deploying to Kubernetes..."

# Apply manifests in order
kubectl apply -f k8s/01-namespace.yaml
sleep 2

kubectl apply -f k8s/02-configmap-secret.yaml
sleep 2

kubectl apply -f k8s/03-auth-service.yaml
kubectl apply -f k8s/04-user-service.yaml
kubectl apply -f k8s/05-product-service.yaml
kubectl apply -f k8s/06-frontend.yaml
sleep 5

# Apply resource quotas
kubectl apply -f k8s/08-resource-quotas.yaml

echo ""
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app -n microservices --timeout=300s 2>/dev/null || true

echo ""
echo "✓ Checking deployment status..."
kubectl get pods -n microservices

echo ""
echo "✅ Deployment complete!"
echo ""
echo "================================"
echo "Access your application:"
echo "================================"
echo ""
echo "Setup port forwarding:"
echo "  kubectl port-forward -n microservices svc/frontend 3000:3000 &"
echo "  kubectl port-forward -n microservices svc/auth-service 5001:5001 &"
echo "  kubectl port-forward -n microservices svc/user-service 5002:5002 &"
echo "  kubectl port-forward -n microservices svc/product-service 5003:5003 &"
echo ""
echo "Then access:"
echo "  Frontend:         http://localhost:3000"
echo "  Auth Service:     http://localhost:5001"
echo "  User Service:     http://localhost:5002"
echo "  Product Service:  http://localhost:5003"
echo ""
echo "Demo Credentials:"
echo "  Email:    user1@example.com"
echo "  Password: password123"
echo ""
echo "Useful kubectl commands:"
echo "  kubectl get pods -n microservices"
echo "  kubectl logs -f -n microservices auth-service-xxx"
echo "  kubectl describe pod -n microservices auth-service-xxx"
echo "  kubectl delete namespace microservices (to cleanup)"
echo ""
echo "================================"
