# Kubernetes Guide

## Kubernetes Basics

### What is Kubernetes (K8s)?

Kubernetes is an open-source container orchestration platform that:
- Automates deployment and scaling of containers
- Manages failure and recovery
- Handles load balancing and networking
- Provides declarative configuration (Infrastructure as Code)

### Key Benefits

- **Automated Deployment**: Deploy containers automatically
- **Self-healing**: Restart failed containers
- **Scaling**: Automatically scale applications up/down
- **Load Balancing**: Distribute traffic across replicas
- **Rolling Updates**: Zero-downtime deployments
- **Resource Management**: Efficient resource utilization
- **High Availability**: Built-in redundancy

## Core Kubernetes Concepts

### Pods

The smallest deployable unit in Kubernetes.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: auth-service-pod
spec:
  containers:
  - name: auth-service
    image: auth-service:latest
    ports:
    - containerPort: 5001
```

**Characteristics**:
- Usually contains one container (can have more)
- Shared storage and networking
- Ephemeral (temporary, replaced during updates)
- Rarely created directly (use Deployments)

### Deployments

Manages replicas of Pods and enables rolling updates.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
spec:
  replicas: 2  # Number of pod copies
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      containers:
      - name: auth-service
        image: auth-service:latest
        ports:
        - containerPort: 5001
```

### Services

Exposes Pods to other Pods/external traffic.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: auth-service
spec:
  type: ClusterIP
  selector:
    app: auth-service
  ports:
  - port: 5001
    targetPort: 5001
```

**Service Types**:
- **ClusterIP**: Internal communication (default)
- **NodePort**: External access via node port
- **LoadBalancer**: External load balancer
- **ExternalName**: DNS name mapping

### Namespaces

Virtual clusters within a Kubernetes cluster.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: microservices
```

**Benefits**:
- Resource isolation
- RBAC boundaries
- Resource quotas and limits
- Multi-tenancy support

### ConfigMaps & Secrets

Store configuration and sensitive data.

```yaml
# ConfigMap for non-sensitive data
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  FLASK_ENV: "production"

# Secret for sensitive data
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  SECRET_KEY: "my-secret-key"
```

### Ingress

Routes external traffic to services.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
spec:
  rules:
  - host: "localhost"
    http:
      paths:
      - path: /
        backend:
          service:
            name: frontend
            port: 3000
```

## Setting Up Kubernetes

### Option 1: Minikube (Local Development)

Minikube runs a single-node Kubernetes cluster locally.

#### Installation

**macOS**:
```bash
brew install minikube kubectl
```

**Windows**:
```bash
choco install minikube kubernetes-cli
```

**Linux**:
```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### Starting Minikube

```bash
# Start cluster
minikube start

# Set Docker environment to Minikube's Docker
eval $(minikube docker-env)

# Verify
kubectl cluster-info
kubectl get nodes
```

#### Stopping Minikube

```bash
# Stop cluster
minikube stop

# Delete cluster
minikube delete
```

### Option 2: Docker Desktop Kubernetes

Enable Kubernetes in Docker Desktop:
1. Open Docker Desktop
2. Preferences → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

### Option 3: Cloud Kubernetes

- **Amazon EKS**: AWS Elastic Kubernetes Service
- **Google GKE**: Google Kubernetes Engine
- **Azure AKS**: Azure Kubernetes Service
- **DigitalOcean DOKS**: DigitalOcean Kubernetes Service

## kubectl Commands

### Cluster Management

```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes
kubectl describe node minikube

# Get namespaces
kubectl get namespaces
```

### Pod Management

```bash
# List pods
kubectl get pods
kubectl get pods -n microservices
kubectl get pods -A  # All namespaces

# Describe pod
kubectl describe pod auth-service-xxx -n microservices

# View pod logs
kubectl logs auth-service-xxx -n microservices
kubectl logs -f auth-service-xxx -n microservices  # Follow logs

# Execute command in pod
kubectl exec -it auth-service-xxx -n microservices -- /bin/sh
```

### Deployment Management

```bash
# List deployments
kubectl get deployments -n microservices

# Describe deployment
kubectl describe deployment auth-service -n microservices

# Scale deployment
kubectl scale deployment auth-service --replicas=3 -n microservices

# Rollout status
kubectl rollout status deployment/auth-service -n microservices

# Rollback deployment
kubectl rollout undo deployment/auth-service -n microservices
```

### Service Management

```bash
# List services
kubectl get services -n microservices

# Describe service
kubectl describe service auth-service -n microservices

# Port forward to access service
kubectl port-forward -n microservices svc/auth-service 5001:5001
```

### Resource Management

```bash
# Get all resources
kubectl get all -n microservices

# Get specific resource type
kubectl get deployments,pods,services -n microservices

# Delete resource
kubectl delete deployment auth-service -n microservices
kubectl delete namespace microservices

# Get resource usage
kubectl top pods -n microservices
kubectl top nodes
```

### Troubleshooting

```bash
# Get events
kubectl get events -n microservices

# Describe error
kubectl describe pod auth-service-xxx -n microservices

# Check logs
kubectl logs auth-service-xxx -n microservices
kubectl logs auth-service-xxx -n microservices --previous  # Previous crash

# Debug pod
kubectl debug pod auth-service-xxx -n microservices

# Check resource status
kubectl api-resources
```

## Deploying the Project to Kubernetes

### Step 1: Build Docker Images

Using Minikube:

```bash
# Set Docker environment
eval $(minikube docker-env)

# Build images
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .
docker build -t user-service:latest -f microservices/user-service/Dockerfile .
docker build -t product-service:latest -f microservices/product-service/Dockerfile .
docker build -t frontend:latest -f frontend/Dockerfile .

# Verify images
docker images
```

### Step 2: Apply Kubernetes Manifests

```bash
# Create namespace
kubectl apply -f k8s/01-namespace.yaml

# Create ConfigMap and Secrets
kubectl apply -f k8s/02-configmap-secret.yaml

# Deploy services (in order)
kubectl apply -f k8s/03-auth-service.yaml
kubectl apply -f k8s/04-user-service.yaml
kubectl apply -f k8s/05-product-service.yaml
kubectl apply -f k8s/06-frontend.yaml

# Apply resource quotas
kubectl apply -f k8s/08-resource-quotas.yaml

# Or apply all at once
kubectl apply -f k8s/
```

### Step 3: Verify Deployment

```bash
# Check pods are running
kubectl get pods -n microservices

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app -n microservices --timeout=300s

# Check services
kubectl get services -n microservices

# Check deployments
kubectl get deployments -n microservices
```

### Step 4: Access the Application

```bash
# Port forward to frontend
kubectl port-forward -n microservices svc/frontend 3000:3000 &

# Port forward to services (if needed)
kubectl port-forward -n microservices svc/auth-service 5001:5001 &
kubectl port-forward -n microservices svc/user-service 5002:5002 &
kubectl port-forward -n microservices svc/product-service 5003:5003 &

# Access at http://localhost:3000
```

## Kubernetes Manifest Explained

### Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: microservices
spec:
  # Number of replicas
  replicas: 2
  
  # Update strategy
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1           # Max extra pods during update
      maxUnavailable: 1     # Max pods that can be unavailable
  
  # Pod selection criteria
  selector:
    matchLabels:
      app: auth-service
  
  # Pod template
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      containers:
      - name: auth-service
        image: auth-service:latest
        ports:
        - containerPort: 5001
        
        # Environment variables
        env:
        - name: FLASK_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: FLASK_ENV
        
        # Resource requests and limits
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        
        # Probes for health checking
        livenessProbe:
          httpGet:
            path: /health
            port: 5001
          initialDelaySeconds: 10
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /health
            port: 5001
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: auth-service
  namespace: microservices
spec:
  type: ClusterIP
  
  # Pod selection
  selector:
    app: auth-service
  
  # Port mapping
  ports:
  - name: http
    port: 5001           # Service port
    targetPort: 5001     # Container port
    protocol: TCP
```

## Health Checks in Kubernetes

### Liveness Probe

Determines if container should be restarted.

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 5001
  initialDelaySeconds: 10   # Wait before first check
  periodSeconds: 10         # Check every 10 seconds
  timeoutSeconds: 5         # Timeout after 5 seconds
  failureThreshold: 3       # Restart after 3 failures
```

### Readiness Probe

Determines if container can receive traffic.

```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 5001
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 2
```

## Resource Management

### Resource Requests

Minimum resources guaranteed:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"      # 0.1 cores
```

### Resource Limits

Maximum resources allowed:

```yaml
resources:
  limits:
    memory: "256Mi"
    cpu: "500m"      # 0.5 cores
```

### Resource Quotas

Namespace-level limits:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: microservices-quota
  namespace: microservices
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "2Gi"
    pods: "20"
```

## Scaling and Updates

### Manual Scaling

```bash
# Scale deployment
kubectl scale deployment auth-service --replicas=5 -n microservices

# Check replicas
kubectl get deployment auth-service -n microservices
```

### Rolling Update

```bash
# Update image
kubectl set image deployment/auth-service auth-service=auth-service:v2 -n microservices

# Watch rollout
kubectl rollout status deployment/auth-service -n microservices

# Rollback if needed
kubectl rollout undo deployment/auth-service -n microservices
```

### Automatic Scaling (HPA)

Horizontal Pod Autoscaler (advanced topic):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: auth-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: auth-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

## Cleanup

```bash
# Delete all resources in namespace
kubectl delete -f k8s/ -n microservices

# Delete namespace (deletes all resources inside)
kubectl delete namespace microservices

# For Minikube cleanup
minikube delete
```

## Best Practices

1. **Use Namespaces**: Organize resources logically
2. **Set Resource Limits**: Control resource consumption
3. **Use Health Checks**: Ensure reliability
4. **Rolling Updates**: Zero-downtime deployments
5. **Use ConfigMaps**: Externalize configuration
6. **Use Secrets**: Avoid hardcoding secrets
7. **Image Tags**: Use specific versions, not `latest`
8. **Readiness Probes**: Ensure pod is ready before traffic
9. **Liveness Probes**: Auto-restart failed containers
10. **Resource Quotas**: Prevent resource exhaustion

## Troubleshooting

```bash
# Pod stuck in pending
kubectl get events -n microservices

# Pod crashes
kubectl logs -f auth-service-xxx -n microservices
kubectl logs -f auth-service-xxx -n microservices --previous

# Service not accessible
kubectl exec -it auth-service-xxx -n microservices -- curl http://auth-service:5001/health

# Debug pod
kubectl debug pod auth-service-xxx -n microservices -it -- /bin/sh
```

---

**Next Steps**:
- [API_REFERENCE.md](API_REFERENCE.md) - API documentation
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Troubleshoot Kubernetes issues
