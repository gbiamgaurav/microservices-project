# Learning Path

## Recommended Learning Sequence

This document provides a structured learning path to understand microservices architecture, Docker, Kubernetes, and related concepts.

## Week 1: Foundation

### Day 1-2: Microservices Basics

**Topics**:
- What are microservices?
- Benefits and challenges
- Microservices vs Monolith
- Service independence

**Activities**:
1. Read [ARCHITECTURE.md](ARCHITECTURE.md) - System design section
2. Examine the project structure
3. Review the three services: Auth, User, Product

**Resources**:
- [Microservices.io](https://microservices.io/) - Microservices patterns
- Sam Newman's "Building Microservices" (book)

---

### Day 3-4: RESTful APIs

**Topics**:
- HTTP methods (GET, POST, PUT, DELETE)
- Status codes
- Request/Response structure
- JSON format

**Activities**:
1. Review [API_REFERENCE.md](API_REFERENCE.md)
2. Test APIs with curl:
   ```bash
   curl http://localhost:5001/health
   curl -X POST http://localhost:5001/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"user1@example.com","password":"password123"}'
   ```
3. Explore each service's endpoints

**Resources**:
- RESTful API Design Best Practices
- HTTP Protocol fundamentals

---

### Day 5: Python & Flask Basics

**Topics**:
- Python fundamentals
- Flask framework
- Route handling
- Request/Response handling

**Activities**:
1. Examine `microservices/auth-service/app.py`
2. Understand Flask decorators: `@app.route()`
3. Study authentication logic
4. Trace request flow

**Resources**:
- Flask Official Documentation
- Python for beginners

---

## Week 2: Containerization

### Day 1-2: Docker Fundamentals

**Topics**:
- What is Docker?
- Images vs Containers
- Dockerfile syntax
- Docker commands

**Activities**:
1. Read [DOCKER_GUIDE.md](DOCKER_GUIDE.md)
2. Understand Dockerfile multi-stage builds
3. Review each service's Dockerfile
4. Study `.dockerignore` files

**Hands-on**:
```bash
# Build an image
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .

# Run container
docker run -p 5001:5001 auth-service:latest

# Check logs
docker logs <container_id>
```

**Resources**:
- Docker Official Documentation
- Docker Hub

---

### Day 3-4: Docker Compose

**Topics**:
- Multi-container applications
- Service dependencies
- Networking
- Health checks
- Environment configuration

**Activities**:
1. Study `docker-compose.yml`
2. Understand service definitions
3. Review network configuration
4. Examine health checks

**Hands-on**:
```bash
# Start all services
docker-compose up

# In another terminal, test
curl http://localhost:5001/health

# View logs
docker-compose logs -f auth-service

# Stop services
docker-compose down
```

---

### Day 5: Docker Best Practices

**Topics**:
- Image optimization
- Layer caching
- Security considerations
- Registry management

**Activities**:
1. Experiment with image sizes
2. Compare Dockerfile approaches
3. Practice tagging images
4. Study image scanning

---

## Week 3: Kubernetes Basics

### Day 1-2: Kubernetes Concepts

**Topics**:
- Pods, Deployments, Services
- Namespaces
- ConfigMaps and Secrets
- Labels and selectors

**Activities**:
1. Read [KUBERNETES_GUIDE.md](KUBERNETES_GUIDE.md) - Core concepts section
2. Review Kubernetes manifests in `k8s/`
3. Understand YAML structure
4. Study resource definitions

**Resources**:
- Kubernetes Official Documentation
- Kubernetes.io concepts

---

### Day 3-4: Local Kubernetes Setup

**Topics**:
- Minikube installation
- kubectl basics
- Local cluster setup
- Image management in Minikube

**Activities**:
1. Install Minikube (see KUBERNETES_GUIDE.md)
2. Start cluster: `minikube start`
3. Verify: `kubectl cluster-info`
4. Learn basic kubectl commands

**Hands-on**:
```bash
# Get cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# Check namespaces
kubectl get namespaces

# Basic pod operations
kubectl run test-pod --image=nginx
kubectl get pods
kubectl describe pod test-pod
```

---

### Day 5: Deploying the Project

**Topics**:
- Building images for Kubernetes
- Applying manifests
- Service discovery
- Port forwarding

**Activities**:
1. Setup Minikube docker environment
2. Build images (see KUBERNETES_GUIDE.md)
3. Apply manifests step by step
4. Verify deployments

**Hands-on**:
```bash
eval $(minikube docker-env)
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .

kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap-secret.yaml
kubectl apply -f k8s/03-auth-service.yaml

kubectl get pods -n microservices
```

---

## Week 4: Advanced Topics

### Day 1: Health Probes & Restart Policies

**Topics**:
- Liveness probes
- Readiness probes
- Restart policies
- Health checks

**Activities**:
1. Study probes in Kubernetes manifests
2. Test health endpoints
3. Understand probe parameters
4. Observe Pod recovery

**Hands-on**:
```bash
# Check pod status
kubectl get pods -n microservices

# Describe pod (see probes)
kubectl describe pod -n microservices auth-service-xxx

# View logs during probe execution
kubectl logs -f -n microservices auth-service-xxx
```

---

### Day 2: Resource Management

**Topics**:
- Resource requests
- Resource limits
- Resource quotas
- Scaling

**Activities**:
1. Review resource definitions in manifests
2. Understand requests vs limits
3. Study ResourceQuota
4. Experiment with scaling

**Hands-on**:
```bash
# Check resource usage
kubectl top pods -n microservices
kubectl top nodes

# Scale deployment
kubectl scale deployment auth-service --replicas=5 -n microservices

# Watch scaling
kubectl get pods -n microservices -w
```

---

### Day 3: Service Discovery & Networking

**Topics**:
- Service types (ClusterIP, NodePort, LoadBalancer)
- Service discovery
- DNS resolution
- Ingress

**Activities**:
1. Review Service definitions
2. Test service communication
3. Understand DNS names
4. Port forward to services

**Hands-on**:
```bash
# Port forward to service
kubectl port-forward -n microservices svc/auth-service 5001:5001 &

# Test service
curl http://localhost:5001/health

# Get service info
kubectl get svc -n microservices
kubectl describe svc auth-service -n microservices
```

---

### Day 4-5: Troubleshooting & Production

**Topics**:
- Common issues and solutions
- Logging and debugging
- YAML validation
- Production readiness

**Activities**:
1. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Practice debugging techniques
3. Learn log analysis
4. Study best practices

**Hands-on**:
```bash
# Get events
kubectl get events -n microservices

# View logs
kubectl logs -n microservices auth-service-xxx

# Describe resources
kubectl describe deployment auth-service -n microservices

# Debug pod
kubectl debug pod auth-service-xxx -n microservices -it -- /bin/sh
```

---

## Week 5: Integration & CI/CD

### Day 1-2: Complete Flow

**Topics**:
- End-to-end application flow
- Frontend to backend communication
- Token authentication
- Error handling

**Activities**:
1. Start complete system (Docker Compose or Kubernetes)
2. Test authentication flow
3. Test service endpoints
4. Trace request/response

**Hands-on**:
```bash
# Start with Docker Compose
docker-compose up

# Or with Kubernetes
kubectl apply -f k8s/

# Test through frontend
# Visit http://localhost:3000
```

---

### Day 3: Monitoring & Logging

**Topics**:
- Container logs
- Service logs
- Metrics collection
- Alerting basics

**Activities**:
1. Practice log commands
2. Understand log output
3. Correlate errors
4. Plan monitoring setup

---

### Day 4-5: CI/CD Introduction

**Topics**:
- Continuous Integration
- Continuous Deployment
- Automated testing
- Build pipelines

**Activities**:
1. Create simple test
2. Understand pipeline concepts
3. Study deployment automation
4. Plan CI/CD workflow

**Resources**:
- GitHub Actions
- GitLab CI/CD
- Jenkins

---

## Recommended Reading Order

1. **README.md** - Project overview
2. **ARCHITECTURE.md** - System design
3. **DOCKER_GUIDE.md** - Local development
4. **KUBERNETES_GUIDE.md** - Production deployment
5. **API_REFERENCE.md** - Service endpoints
6. **TROUBLESHOOTING.md** - Debugging
7. **LEARNING_PATH.md** - This document

---

## Hands-On Practice Exercises

### Exercise 1: Service Modification
- Modify auth-service to add a new endpoint `/health/detailed`
- Test the new endpoint
- Rebuild Docker image
- Redeploy to Kubernetes

### Exercise 2: Service Communication
- Create a call from frontend to product service
- Test the communication flow
- Debug any issues

### Exercise 3: Scaling
- Scale auth-service to 5 replicas
- Verify load distribution
- Observe logs from different pods

### Exercise 4: Debugging
- Intentionally break a service
- Use kubectl debugging tools to identify issue
- Fix and redeploy

### Exercise 5: Monitoring
- Add prometheus metrics to a service
- Visualize metrics with Grafana
- Create basic dashboards

---

## Key Milestones

**Week 1**: ✓ Understand microservices and APIs
**Week 2**: ✓ Build and run containers locally
**Week 3**: ✓ Deploy to Kubernetes locally
**Week 4**: ✓ Master Kubernetes operations
**Week 5**: ✓ Build complete applications with orchestration

---

## Next Steps After Completing Path

1. **Advanced Kubernetes**:
   - Service Mesh (Istio)
   - GitOps (ArgoCD)
   - Network Policies
   - RBAC

2. **DevOps Tools**:
   - CI/CD Pipelines (Jenkins, GitHub Actions)
   - Infrastructure as Code (Terraform)
   - Configuration Management (Ansible)

3. **Cloud Platforms**:
   - AWS EKS
   - Google GKE
   - Azure AKS

4. **Production Deployments**:
   - Database integration
   - Monitoring & alerting
   - Security hardening
   - Performance optimization

---

## Resources Summary

### Free Online Courses
- Kubernetes course on Linux Academy
- Docker course on Udemy
- Microservices course on Coursera

### Documentation
- [Kubernetes.io](https://kubernetes.io/)
- [Docker Docs](https://docs.docker.com/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [React Documentation](https://react.dev/)

### Books
- "Building Microservices" by Sam Newman
- "The Kubernetes Book" by Nigel Poulton
- "Docker Deep Dive" by Nigel Poulton

### Community
- Stack Overflow
- Kubernetes Slack
- Docker Community Forums

---

## Tips for Success

1. **Practice consistently**: Daily hands-on practice is more valuable than theory alone
2. **Break things**: Intentionally break services and learn to fix them
3. **Read manifests**: Understand every line of YAML
4. **Debug systematically**: Use logs and describe commands methodically
5. **Document learnings**: Keep notes on what you discover
6. **Build confidence**: Complete small projects before tackling large ones
7. **Join communities**: Learn from others' experiences
8. **Stay updated**: Technology evolves; keep learning

---

**Good luck on your learning journey!** 🚀

Start with Week 1 and progress systematically through the course material.
