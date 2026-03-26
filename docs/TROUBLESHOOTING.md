# Troubleshooting Guide

## Common Issues and Solutions

---

## Docker Issues

### Issue 1: "Cannot connect to Docker daemon"

**Error Message**:
```
Cannot connect to Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

**Solutions**:
```bash
# macOS - Docker Desktop not running
# Open Docker Desktop application

# Linux - Docker daemon not started
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker is running
docker ps
```

---

### Issue 2: "Port already in use"

**Error Message**:
```
Bind for 0.0.0.0:5001 failed: port is already allocated
```

**Solutions**:
```bash
# Find process using the port
lsof -i :5001

# Kill the process
kill -9 <PID>

# Or use a different port
docker run -p 5002:5001 auth-service:latest

# Or stop existing container
docker-compose down
```

---

### Issue 3: "Image not found"

**Error Message**:
```
docker: Error response from daemon: pull access denied for auth-service, repository does not exist
```

**Solutions**:
```bash
# Build the image first
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .

# Or check image name
docker images

# Verify Dockerfile path
ls microservices/auth-service/Dockerfile
```

---

### Issue 4: "Container exits immediately"

**Error Message**:
```
Container exited with status code 1
```

**Solutions**:
```bash
# Check logs
docker logs <container_id>

# Run interactively to see errors
docker run -it auth-service:latest /bin/bash

# Check requirements.txt
cat microservices/auth-service/requirements.txt

# Verify app.py syntax
python -m py_compile microservices/auth-service/app.py
```

---

### Issue 5: "Out of disk space"

**Error Message**:
```
no space left on device
```

**Solutions**:
```bash
# Clean up Docker
docker system prune -a

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Check disk space
df -h
```

---

## Docker Compose Issues

### Issue 1: "Service not reachable"

**Problem**: Can't reach service at `localhost:PORT`

**Solutions**:
```bash
# Verify services are running
docker-compose ps

# Check service status
docker-compose logs auth-service

# Verify port mapping
docker-compose ps auth-service

# Test from inside network
docker-compose exec auth-service curl http://localhost:5001/health
```

---

### Issue 2: "Health check failing"

**Error Message**:
```
unhealthy
```

**Solutions**:
```bash
# Check health check logs
docker-compose logs auth-service

# Test health endpoint manually
curl http://localhost:5001/health

# Verify service is responding
docker-compose exec auth-service /bin/sh
# Inside container: curl localhost:5001/health

# Adjust health check parameters in docker-compose.yml
# Increase initialDelaySeconds if startup time is long
```

---

### Issue 3: "Services can't communicate"

**Problem**: One service can't reach another

**Solutions**:
```bash
# Verify both services are running
docker-compose ps

# Test connectivity
docker-compose exec auth-service curl http://user-service:5002/health

# Check network
docker network ls
docker network inspect microservices-network

# Verify service names match docker-compose.yml
docker-compose config
```

---

### Issue 4: "Environment variables not set"

**Problem**: Service not reading environment variables

**Solutions**:
```bash
# Check environment in container
docker-compose exec auth-service env

# Verify docker-compose.yml
cat docker-compose.yml | grep -A 5 "environment:"

# Check .env file exists
cat .env

# Manually test environment
docker-compose exec auth-service echo $SECRET_KEY
```

---

## Kubernetes Issues

### Issue 1: "Pod stuck in Pending state"

**Error Message**:
```
STATUS: Pending
```

**Solutions**:
```bash
# Check events
kubectl get events -n microservices

# Describe pod
kubectl describe pod auth-service-xxx -n microservices

# Common causes and fixes:
# 1. No resource available
kubectl describe nodes

# 2. Image not available
kubectl describe pod auth-service-xxx -n microservices | grep Image

# 3. Resource limits exceeded
kubectl get resourcequota -n microservices
```

---

### Issue 2: "ImagePullBackOff" or "ImagePullError"

**Error Message**:
```
Failed to pull image "auth-service:latest"
```

**Solutions**:
```bash
# Build image for Minikube
eval $(minikube docker-env)
docker build -t auth-service:latest -f microservices/auth-service/Dockerfile .

# Verify image is available
docker images | grep auth-service

# Check image pull policy
kubectl describe pod auth-service-xxx -n microservices | grep imagePullPolicy

# For remote registries, check credentials
kubectl get secrets -n microservices
```

---

### Issue 3: "Pod CrashLoopBackOff"

**Error Message**:
```
STATUS: CrashLoopBackOff
```

**Solutions**:
```bash
# Check logs
kubectl logs auth-service-xxx -n microservices

# Check previous logs (before crash)
kubectl logs auth-service-xxx -n microservices --previous

# Describe pod
kubectl describe pod auth-service-xxx -n microservices

# Check resource limits
kubectl describe deployment auth-service -n microservices

# Test pod directly
kubectl debug pod auth-service-xxx -n microservices -it -- /bin/bash
```

---

### Issue 4: "Service not accessible"

**Problem**: Can't reach service after port-forward

**Solutions**:
```bash
# Verify service exists
kubectl get svc -n microservices

# Verify pods are running
kubectl get pods -n microservices

# Check service selector matches pod labels
kubectl describe svc auth-service -n microservices
kubectl get pods -n microservices --show-labels

# Try port-forward again
kubectl port-forward -n microservices svc/auth-service 5001:5001

# Verify endpoint is ready
kubectl get endpoints -n microservices
```

---

### Issue 5: "ConfigMap or Secret not found"

**Error Message**:
```
couldn't find key FLASK_ENV
```

**Solutions**:
```bash
# Verify ConfigMap exists
kubectl get configmap -n microservices

# Check ConfigMap contents
kubectl describe configmap app-config -n microservices

# Verify Secret exists
kubectl get secret -n microservices

# Check what's in secret
kubectl describe secret app-secrets -n microservices

# Recreate if needed
kubectl apply -f k8s/02-configmap-secret.yaml
```

---

### Issue 6: "Pod has unbound PersistentVolumeClaim"

**Error Message**:
```
persistentvolumeclaim not found
```

**Solutions**:
```bash
# Verify PVC exists
kubectl get pvc -n microservices

# Create PVC if needed
kubectl apply -f pvc-manifest.yaml

# Check PV status
kubectl get pv
```

---

## Network and Connectivity Issues

### Issue 1: "DNS resolution failed"

**Problem**: Can't resolve service names

**Solutions**:
```bash
# Check DNS
kubectl get svc -n kube-system | grep dns

# Test DNS from pod
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup auth-service.microservices

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

---

### Issue 2: "Connection refused"

**Problem**: Service is running but connection is refused

**Solutions**:
```bash
# Verify service is listening
kubectl exec -it auth-service-xxx -n microservices -- netstat -tlnp

# Check service endpoints
kubectl get endpoints -n microservices

# Verify pod is ready
kubectl get pods -n microservices -o wide

# Check readiness probe
kubectl describe pod auth-service-xxx -n microservices | grep Readiness
```

---

## Application-Level Issues

### Issue 1: "Authentication token not working"

**Problem**: JWT token rejected or not recognized

**Solutions**:
```bash
# Get token
TOKEN=$(curl -X POST http://localhost:5001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user1@example.com","password":"password123"}' \
  | jq -r '.token')

# Verify token
curl http://localhost:5001/auth/verify \
  -H "Authorization: Bearer $TOKEN"

# Check token expiration
# Tokens are configured for 24 hours

# Check SECRET_KEY matches
kubectl get secret app-secrets -n microservices -o yaml
```

---

### Issue 2: "API returns 404"

**Problem**: Endpoint not found

**Solutions**:
```bash
# Check available endpoints
curl http://localhost:5001/health

# Verify correct service port
curl http://localhost:5002/users  # User service
curl http://localhost:5003/products  # Product service

# Check application logs
kubectl logs -n microservices auth-service-xxx

# Verify Flask routes in code
docker-compose exec auth-service grep -n "@app.route" app.py
```

---

### Issue 3: "Slow API response"

**Problem**: API calls are slow

**Solutions**:
```bash
# Check pod resources
kubectl top pods -n microservices

# Check if resource limits exceeded
kubectl describe pod auth-service-xxx -n microservices

# Check node resources
kubectl top nodes

# Increase replicas for load distribution
kubectl scale deployment auth-service --replicas=5 -n microservices

# Monitor performance
kubectl get events -n microservices
```

---

## Database Issues (if integrated)

### Issue 1: "Database connection refused"

**Solutions**:
```bash
# Verify database pod is running
kubectl get pods -n microservices -l app=database

# Check database service
kubectl get svc -n microservices | grep database

# Test connectivity
kubectl port-forward -n microservices svc/database 5432:5432
# Then test locally

# Check database logs
kubectl logs -n microservices database-xxx
```

---

## Debugging Techniques

### 1. Check Logs

```bash
# Recent logs
kubectl logs -n microservices auth-service-xxx

# Follow logs in real-time
kubectl logs -f -n microservices auth-service-xxx

# Last 100 lines
kubectl logs -n microservices auth-service-xxx --tail=100

# Previous crashed pod logs
kubectl logs -n microservices auth-service-xxx --previous
```

### 2. Describe Resources

```bash
# Pod details
kubectl describe pod auth-service-xxx -n microservices

# Deployment details
kubectl describe deployment auth-service -n microservices

# Service details
kubectl describe service auth-service -n microservices
```

### 3. Shell Access

```bash
# Execute command
kubectl exec -it auth-service-xxx -n microservices -- ls -la

# Interactive shell
kubectl exec -it auth-service-xxx -n microservices -- /bin/bash

# Debug pod (empty pod for debugging)
kubectl debug pod auth-service-xxx -n microservices -it -- /bin/sh
```

### 4. Port Forwarding

```bash
# Forward pod port
kubectl port-forward -n microservices pod/auth-service-xxx 5001:5001

# Forward service port
kubectl port-forward -n microservices svc/auth-service 5001:5001
```

### 5. Test Connectivity

```bash
# From pod to service
kubectl exec -it auth-service-xxx -n microservices -- curl http://user-service:5002/health

# DNS test
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup auth-service.microservices
```

### 6. Check Events

```bash
# Watch events
kubectl get events -n microservices -w

# Get all recent events
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

---

## System Information

### Check Cluster Status

```bash
# Cluster info
kubectl cluster-info

# Nodes
kubectl get nodes
kubectl describe nodes

# Version
kubectl version

# API resources
kubectl api-resources
```

### Check Minikube

```bash
# Minikube status
minikube status

# Minikube logs
minikube logs

# Minikube dashboard
minikube dashboard

# SSH into Minikube
minikube ssh
```

---

## Performance Issues

### High CPU Usage

```bash
# Check resource usage
kubectl top pods -n microservices

# Increase resource limits
# Edit deployment and increase limits

# Add more replicas
kubectl scale deployment auth-service --replicas=5 -n microservices
```

### High Memory Usage

```bash
# Check memory usage
kubectl top pods -n microservices

# Check for memory leaks in logs
kubectl logs -f -n microservices auth-service-xxx

# Increase memory limits
kubectl set resources deployment auth-service --limits=memory=512Mi -n microservices
```

---

## Windows Specific Issues

### Issue 1: "Minikube fails to start"

**Solutions**:
```bash
# Enable Hyper-V
# Admin PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName Hyper-V

# Or use VirtualBox instead
minikube start --driver=virtualbox
```

### Issue 2: "Line endings issues (CRLF vs LF)"

**Solutions**:
```bash
# Convert files
dos2unix microservices/auth-service/app.py

# Or configure git
git config --global core.autocrlf input
```

---

## Quick Reference: Common Fixes

| Issue | Fix |
|-------|-----|
| Container won't start | `docker logs <id>` |
| Can't reach service | `docker-compose ps` |
| Out of space | `docker system prune -a` |
| Pod pending | `kubectl describe pod` |
| Image not found | `kubectl describe pod` |
| Pod crashloop | `kubectl logs --previous` |
| Can't connect | `kubectl get events` |
| No endpoints | `kubectl describe svc` |
| DNS issues | `kubectl run debug` |
| Slow response | `kubectl top pods` |

---

## Getting Help

### Resources

1. **Check logs first** - 90% of issues are in the logs
2. **Search the error** - Most common issues have solutions
3. **Ask in communities** - Kubernetes Slack, Stack Overflow
4. **Read documentation** - Official docs are comprehensive

### When Creating Issues

Include:
- Error message
- Logs output
- kubectl describe output
- Steps to reproduce
- Environment info

---

## Prevention Tips

1. **Monitor health checks** - Set up proper probes
2. **Resource management** - Always set requests and limits
3. **Logging** - Check logs regularly
4. **Testing** - Test in Minikube before production
5. **Documentation** - Document your setup
6. **Backup** - Keep manifests in version control
7. **Updates** - Keep tools updated

---

**Next Steps**:
- Review specific error in this guide
- Check official documentation
- Ask in community forums if unresolved
- File an issue with reproduction steps

---

**Happy troubleshooting!** 🔧

Remember: The best debugging tool is a clear head and methodical approach.
