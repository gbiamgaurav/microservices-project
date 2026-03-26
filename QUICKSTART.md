# Getting Started - Quick Reference

## For Complete Beginners

### Step 1: Install Requirements

**macOS**:
```bash
brew install docker
brew install kubectl
brew install minikube
```

**Windows**: 
- Download Docker Desktop: https://www.docker.com/products/docker-desktop
- Download kubectl and minikube from their websites

**Linux**:
```bash
# See detailed instructions in DOCKER_GUIDE.md and KUBERNETES_GUIDE.md
```

---

## Option A: Docker Compose (Easiest - Start Here)

### Quick Start

```bash
# Navigate to project
cd microservices-project

# Make script executable
chmod +x quickstart.sh

# Run quick start
./quickstart.sh
```

### Manual Start

```bash
# Build and start all services
docker-compose up --build

# Open http://localhost:3000 in browser
```

### Login Credentials

- **Email**: `user1@example.com`
- **Password**: `password123`

### Stop Services

```bash
docker-compose down
```

---

## Option B: Kubernetes (Advanced - After Docker Mastery)

### Quick Start

```bash
# Make script executable
chmod +x k8s-quickstart.sh

# Deploy to Kubernetes
./k8s-quickstart.sh

# Setup port forwarding in another terminal
kubectl port-forward -n microservices svc/frontend 3000:3000
```

### Manual Deployment

```bash
# Start Minikube
minikube start

# Set Docker environment
eval $(minikube docker-env)

# Build images
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .
docker build -t user-service:latest -f microservices/user-service/Dockerfile .
docker build -t product-service:latest -f microservices/product-service/Dockerfile .
docker build -t frontend:latest -f frontend/Dockerfile .

# Deploy
kubectl apply -f k8s/

# Port forward
kubectl port-forward -n microservices svc/frontend 3000:3000
```

---

## Documentation Index

| Document | For Learning | Purpose |
|----------|--------------|---------|
| [README.md](README.md) | First | Project overview |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Second | System design |
| [DOCKER_GUIDE.md](docs/DOCKER_GUIDE.md) | Third | Docker tutorial |
| [KUBERNETES_GUIDE.md](docs/KUBERNETES_GUIDE.md) | Fourth | K8s tutorial |
| [API_REFERENCE.md](docs/API_REFERENCE.md) | Reference | API endpoints |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | When stuck | Debugging help |
| [LEARNING_PATH.md](docs/LEARNING_PATH.md) | Planning | 5-week learning plan |

---

## File Structure

```
microservices-project/
├── README.md                    ← Start here
├── quickstart.sh               ← Run for Docker Compose
├── k8s-quickstart.sh          ← Run for Kubernetes
├── .env.example               ← Configuration template
├── docker-compose.yml         ← Docker Compose file

├── microservices/
│   ├── auth-service/
│   │   ├── app.py            ← Service code
│   │   ├── requirements.txt   ← Dependencies
│   │   ├── Dockerfile        ← Container image
│   │   └── .dockerignore
│   ├── user-service/         ← Similar structure
│   └── product-service/      ← Similar structure

├── frontend/
│   ├── App.jsx               ← Main React component
│   ├── App.css               ← Styling
│   ├── package.json          ← Dependencies
│   ├── vite.config.js        ← Build config
│   ├── Dockerfile
│   └── .dockerignore

├── k8s/                       ← Kubernetes manifests
│   ├── 01-namespace.yaml
│   ├── 02-configmap-secret.yaml
│   ├── 03-auth-service.yaml
│   ├── 04-user-service.yaml
│   ├── 05-product-service.yaml
│   ├── 06-frontend.yaml
│   ├── 07-ingress.yaml
│   └── 08-resource-quotas.yaml

└── docs/                      ← Documentation
    ├── ARCHITECTURE.md
    ├── DOCKER_GUIDE.md
    ├── KUBERNETES_GUIDE.md
    ├── API_REFERENCE.md
    ├── TROUBLESHOOTING.md
    └── LEARNING_PATH.md
```

---

## What's Included

### 3 Python Microservices
- **Auth Service** (Port 5001): Authentication and JWT tokens
- **User Service** (Port 5002): User management
- **Product Service** (Port 5003): Product catalog

### React Frontend
- **Port**: 3000
- **Features**: Login, user list, product list
- **Technology**: React + Vite + Axios

### Docker Setup
- Dockerfiles for each service
- Multi-stage builds for optimization
- docker-compose.yml with health checks
- .dockerignore files

### Kubernetes Setup
- 8 manifest files for complete deployment
- Deployments, Services, ConfigMaps, Secrets
- Resource quotas and limits
- Health probes (liveness & readiness)

### Documentation
- 7 comprehensive guides
- Learning path (5 weeks)
- API reference with examples
- Troubleshooting guide

---

## Next Steps After Starting

### With Docker Compose:
1. ✓ Start services with `docker-compose up`
2. Open http://localhost:3000
3. Login and explore the UI
4. Read DOCKER_GUIDE.md to understand more
5. Read ARCHITECTURE.md to learn design patterns

### With Kubernetes:
1. ✓ Deploy with `kubectl apply -f k8s/`
2. Port-forward with `kubectl port-forward`
3. Open http://localhost:3000
4. Read KUBERNETES_GUIDE.md to understand more
5. Practice kubectl commands from KUBERNETES_GUIDE.md

---

## Common Commands

### Docker Compose

```bash
docker-compose up              # Start services
docker-compose down            # Stop services
docker-compose logs -f app     # View logs
docker-compose ps              # Check status
```

### Kubernetes

```bash
kubectl apply -f k8s/                    # Deploy
kubectl get pods -n microservices        # List pods
kubectl logs -f -n microservices auth-service-xxx   # Logs
kubectl delete namespace microservices   # Cleanup
```

### Testing APIs

```bash
# Health check
curl http://localhost:5001/health

# Login
TOKEN=$(curl -X POST http://localhost:5001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user1@example.com","password":"password123"}' | jq -r '.token')

# Use token
curl http://localhost:5002/users \
  -H "Authorization: Bearer $TOKEN"
```

---

## Learning Tips

1. **Start Simple**: Use Docker Compose first, then move to Kubernetes
2. **Read Logs**: 90% of issues are visible in logs
3. **Understand Code**: Review the Python and React source files
4. **Follow Learning Path**: LEARNING_PATH.md has a structured plan
5. **Experiment**: Modify code and rebuild to reinforce learning
6. **Ask Questions**: Check TROUBLESHOOTING.md or search online

---

## Video Tutorial Pattern

This project follows this learning flow:

```
1. Services (Python)
   ↓
2. Containerization (Docker)
   ↓
3. Local Orchestration (Docker Compose)
   ↓
4. Advanced Containers (Kubernetes)
   ↓
5. Production Deployment
```

---

## Need Help?

1. **Setup Issues**: See TROUBLESHOOTING.md
2. **Understanding Architecture**: Read ARCHITECTURE.md
3. **Docker Questions**: Read DOCKER_GUIDE.md
4. **Kubernetes Questions**: Read KUBERNETES_GUIDE.md
5. **API Usage**: Read API_REFERENCE.md
6. **Learning Plan**: Follow LEARNING_PATH.md

---

## Key Concepts Learned

After completing this project, you'll understand:

✓ Microservices architecture  
✓ REST APIs and HTTP protocols  
✓ Docker containerization  
✓ Docker Compose for local development  
✓ Kubernetes fundamentals  
✓ Container orchestration  
✓ Service discovery  
✓ Health checks and probes  
✓ Resource management  
✓ Deployment strategies  

---

**Ready to start?**

🐳 **Docker Compose**: `./quickstart.sh`

☸️ **Kubernetes**: `./k8s-quickstart.sh`

📚 **Learning**: Read [LEARNING_PATH.md](docs/LEARNING_PATH.md)

---

Made with ❤️ for learning purposes.
