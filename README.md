# Microservices Architecture with React Frontend - Learning Project

A comprehensive learning project demonstrating a complete microservices architecture with Python backend services, React frontend, Docker containerization, and Kubernetes orchestration.

## Project Overview

This project showcases:
- **Microservices Architecture**: Three independent Python Flask services (Auth, User, Product)
- **Frontend**: Modern React application with Vite
- **Containerization**: Docker files and Docker Compose for local development
- **Orchestration**: Kubernetes manifests for production deployment
- **CI/CD Ready**: Structured for easy integration with CI/CD pipelines

## Project Structure

```
microservices-project/
├── microservices/
│   ├── auth-service/          # Authentication service
│   ├── user-service/          # User management service
│   └── product-service/       # Product catalog service
├── frontend/                   # React Vite application
├── k8s/                        # Kubernetes manifests
├── docs/                       # Documentation
├── docker-compose.yml         # Docker Compose configuration
└── .env                        # Environment variables
```

## Quick Start

### Using Docker Compose (Development)

```bash
# Build and start all services
docker-compose up --build

# Services will be available at:
# Frontend: http://localhost:3000
# Auth Service: http://localhost:5001
# User Service: http://localhost:5002
# Product Service: http://localhost:5003
```

### Using Kubernetes (Production-like)

```bash
# 1. Build images with a local registry (example using Minikube)
eval $(minikube docker-env)
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .
docker build -t user-service:latest -f microservices/user-service/Dockerfile .
docker build -t product-service:latest -f microservices/product-service/Dockerfile .
docker build -t frontend:latest -f frontend/Dockerfile .

# 2. Apply Kubernetes manifests
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap-secret.yaml
kubectl apply -f k8s/03-auth-service.yaml
kubectl apply -f k8s/04-user-service.yaml
kubectl apply -f k8s/05-product-service.yaml
kubectl apply -f k8s/06-frontend.yaml
kubectl apply -f k8s/08-resource-quotas.yaml

# 3. Port forwarding to access services
kubectl port-forward -n microservices svc/frontend 3000:3000 &
kubectl port-forward -n microservices svc/auth-service 5001:5001 &
kubectl port-forward -n microservices svc/user-service 5002:5002 &
kubectl port-forward -n microservices svc/product-service 5003:5003 &
```

## Demo Credentials

Use these credentials to login to the frontend:
- **Email**: `user1@example.com`
- **Password**: `password123`

Alternative:
- **Email**: `user2@example.com`
- **Password**: `password456`

## Services

### Auth Service (Port: 5001)
Handles user authentication and JWT token generation.

**Endpoints**:
- `GET /health` - Health check
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token
- `POST /auth/verify` - Verify JWT token
- `POST /auth/refresh` - Refresh JWT token

### User Service (Port: 5002)
Manages user profiles and information.

**Endpoints**:
- `GET /health` - Health check
- `GET /users` - Get all users
- `GET /users/<id>` - Get specific user
- `PUT /users/<id>` - Update user
- `DELETE /users/<id>` - Delete user
- `GET /users/profile/<id>` - Get user profile

### Product Service (Port: 5003)
Manages product catalog and inventory.

**Endpoints**:
- `GET /health` - Health check
- `GET /products` - Get all products
- `GET /products/<id>` - Get specific product
- `POST /products` - Create product
- `PUT /products/<id>` - Update product
- `DELETE /products/<id>` - Delete product
- `GET /products/<id>/stock` - Check product stock

## Requirements

- Docker & Docker Compose (for local development)
- Kubernetes cluster (for K8s deployment)
- kubectl (for K8s management)
- Node.js 18+ (for frontend development, optional)
- Python 3.11+ (for service development, optional)

## Documentation

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - System design and architecture
- [DOCKER_GUIDE.md](docs/DOCKER_GUIDE.md) - Docker setup and deployment
- [KUBERNETES_GUIDE.md](docs/KUBERNETES_GUIDE.md) - Kubernetes deployment guide
- [API_REFERENCE.md](docs/API_REFERENCE.md) - Detailed API documentation
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [LEARNING_PATH.md](docs/LEARNING_PATH.md) - Learning resources

## Key Concepts Covered

✓ Microservices Architecture  
✓ Container Orchestration with Docker  
✓ Container Production Deployment with Kubernetes  
✓ React Frontend Development  
✓ REST API Design  
✓ Health Checks and Probes  
✓ Resource Management  
✓ Service Discovery  
✓ Load Balancing  
✓ Network Policies  

## Environment Variables

```bash
SECRET_KEY=your-secret-key-change-in-production
VITE_API_URL=http://localhost:5000
FLASK_ENV=development
```

## Common Commands

```bash
# Docker Compose
docker-compose up                    # Start services
docker-compose down                  # Stop services
docker-compose logs -f auth-service  # View logs
docker-compose ps                    # List running containers

# Kubernetes
kubectl get pods -n microservices           # List pods
kubectl logs -n microservices auth-service  # View pod logs
kubectl describe pod -n microservices auth-service-xxx
kubectl exec -it -n microservices auth-service-xxx -- /bin/sh  # Shell access
```

## Production Considerations

1. **Image Registry**: Push images to Docker Hub, ECR, or GCR
2. **Secrets Management**: Use proper secret management (not hardcoded)
3. **Database**: Add persistent storage and proper databases
4. **Monitoring**: Integrate with Prometheus, Grafana, ELK stack
5. **Logging**: Centralize logs with ELK or similar
6. **SSL/TLS**: Configure proper HTTPS certificates
7. **API Gateway**: Consider Kong, Envoy, or similar for advanced routing
8. **Rate Limiting**: Implement per-service rate limiting
9. **Circuit Breakers**: Add resilience patterns
10. **Auto-scaling**: Configure HPA for automatic scaling

## Learning Objectives

By completing this project, you will learn:
- How to build scalable microservices
- Docker containerization best practices
- Kubernetes deployment and management
- React component development
- RESTful API design
- Service communication patterns
- Infrastructure as Code (IaC)

## Troubleshooting

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions.

## Contributing

This is a learning project. Feel free to modify, extend, and experiment!

## License

Educational - Free to use for learning purposes.

## Support

For questions and issues:
1. Check the documentation
2. Review logs: `docker-compose logs` or `kubectl logs`
3. Verify service health: `curl http://localhost:PORT/health`
4. Check networking: `docker network ls` or `kubectl get svc`

---

**Happy Learning!** 🚀

Start with [LEARNING_PATH.md](docs/LEARNING_PATH.md) to understand the recommended learning sequence.
