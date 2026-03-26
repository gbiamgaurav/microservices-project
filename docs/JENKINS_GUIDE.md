# Jenkins CI/CD Pipeline Guide

Complete guide to set up and use Jenkins CI/CD pipeline for your microservices project.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Jenkins Setup](#jenkins-setup)
4. [Pipeline Configuration](#pipeline-configuration)
5. [Triggering Builds](#triggering-builds)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Prerequisites

- Local machine with Docker installed
- Azure account with AKS cluster running
- Azure Container Registry (ACR) set up
- GitHub account and repository
- GitHub personal access token

---

## Installation

### Option 1: Using Docker Compose (Recommended)

```bash
# Navigate to your project
cd microservices-project

# Start Jenkins and SonarQube
docker compose -f jenkins-compose.yml up -d

# Check status
docker compose -f jenkins-compose.yml ps

# Get initial admin password
docker logs microservices-jenkins 2>&1 | grep -A 5 "Jenkins initial setup"
```

Jenkins will be available at: **http://localhost:8080**

### Option 2: Using Homebrew (macOS)

```bash
# Install Jenkins
brew install jenkins-lts

# Start Jenkins
brew services start jenkins-lts

# Jenkins runs at http://localhost:8080

# View logs
brew services log jenkins-lts
```

### Option 3: Using Docker (Standalone)

```bash
docker run -d \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins-home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins \
  jenkins/jenkins:lts
```

---

## Jenkins Setup

### Step 1: Initial Admin Setup

1. Open http://localhost:8080
2. Retrieve admin password:
   ```bash
   # Docker Compose
   docker compose -f jenkins-compose.yml exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   
   # Docker standalone
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

3. Paste password in web UI
4. Create admin user account
5. Install suggested plugins (click "Install suggested plugins")

### Step 2: Install Additional Plugins

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Search and install:
   - Docker Plugin
   - Kubernetes Plugin
   - GitHub Integration
   - Azure Credentials
   - Pipeline
   - Blue Ocean (optional - better UI)
   - SonarQube Scanner (optional)
   - Slack Plugin (optional - for notifications)

### Step 3: Configure System

1. Go to **Manage Jenkins** → **Configure System**
2. Find **Docker** section:
   - Docker URL: `unix:///var/run/docker.sock` (for local Docker)
   - Docker API version: Leave empty
3. Find **GitHub** section:
   - GitHub Server: GitHub.com
4. Click **Save**

### Step 4: Add Credentials

Go to **Manage Jenkins** → **Manage Credentials** → **System** → **Global credentials**

#### Add GitHub Token
- Click **Add Credentials**
- Kind: **Secret text**
- Secret: Your GitHub personal access token
- ID: `github-token`
- Description: `GitHub Personal Access Token`
- Click **Create**

#### Add Docker Registry Credentials
- Click **Add Credentials**
- Kind: **Username with password**
- Username: Your ACR username
- Password: Your ACR password
- ID: `azure-acr-credentials`
- Description: `Azure Container Registry`
- Click **Create**

#### Add AKS Kubeconfig
- Get kubeconfig:
  ```bash
  az aks get-credentials \
    --resource-group microservices-rg \
    --name microservices-aks \
    --file kubeconfig.yaml
  ```

- Click **Add Credentials**
- Kind: **Secret file**
- File: Select the `kubeconfig.yaml` file
- ID: `aks-kubeconfig`
- Description: `AKS Kubeconfig`
- Click **Create**

---

## Pipeline Configuration

### Create Pipeline Job

1. Click **New Item**
2. Enter name: `microservices-pipeline`
3. Select **Pipeline** → **OK**

### Configure Pipeline

In the **Pipeline** section:

- **Definition**: Select `Pipeline script from SCM`

### Configure Source Control (SCM)

- **SCM**: Select `Git`
- **Repository URL**: `https://github.com/yourusername/microservices-project`
- **Credentials**: Select `github-token`
- **Branches to build**: `*/main` (or `*/develop` for staging)
- **Repository browser**: GitHub
- **Script Path**: `Jenkinsfile`

### Save Configuration

Click **Save**

---

## Triggering Builds

### Method 1: Manual Trigger

1. Open your pipeline job
2. Click **Build Now**
3. Go to pipeline logs to view progress

### Method 2: GitHub Webhook (Automatic)

#### Configure Webhook in GitHub

1. Go to GitHub repo → **Settings** → **Webhooks**
2. Click **Add webhook**
3. Fill in:
   - **Payload URL**: `http://YOUR_JENKINS_IP:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: Select `Just the push event`
   - **Active**: ✅ Check this box
4. Click **Add webhook**

#### Test Webhook

```bash
# Push a change to main branch
git add .
git commit -m "Trigger pipeline"
git push origin main

# Pipeline should start automatically!
```

---

## Understanding Pipeline Output

### Build Console Output

Each stage displays progress:

```
[Pipeline] stage('Checkout')
⏱️  Checked out at revision abc123def456

[Pipeline] stage('Build Docker Images')
⏱️  Building 4 Docker images...
✅  All images built successfully

[Pipeline] stage('Run Tests')
⏱️  Running unit tests...
✅  Tests passed

[Pipeline] stage('Security Scan')
⏱️  Running security scan...
⚠️  3 medium severity vulnerabilities found
✅  No critical vulnerabilities

[Pipeline] stage('Push to Azure Registry')
✅  Images pushed successfully

[Pipeline] stage('Deploy to Staging')
✅  Deployed to staging successfully

[Pipeline] stage('Integration Tests')
✅  All integration tests passed

[Pipeline] stage('Manual Approval')
⏸️  PAUSED - Waiting for approval

👤 You clicked "Proceed"

[Pipeline] stage('Deploy to Production')
✅  Production deployment started
✅  Rolling update in progress
✅  All pods are ready
✅  Production deployment completed
```

---

## Viewing Pipeline History

### Option 1: Classic UI

1. Open Jenkins dashboard
2. Click your pipeline name
3. View **Build History** on left sidebar

### Option 2: Blue Ocean (Better)

1. Install Blue Ocean plugin
2. Go to `http://localhost:8080/blue`
3. See visual pipeline flow

---

## Pipeline Stages Breakdown

### 1. **Checkout**
- Clones repository from GitHub
- Extract commit hash for tagging

### 2. **Build Docker Images**
- Builds 4 images: auth, user, product, frontend
- Tags with build number and commit hash

### 3. **Run Tests**
- Executes unit tests in containers
- Reports pass/fail

### 4. **Security Scan**
- Scans images for vulnerabilities with Trivy
- Blocks deployment on critical vulnerabilities

### 5. **Push to Azure Registry**
- Logs into Azure Container Registry
- Pushes all 4 images
- Creates `latest` and versioned tags

### 6. **Deploy to Staging**
- Deploys to staging Kubernetes namespace
- Minimal resources for testing

### 7. **Integration Tests**
- Tests all API endpoints
- Verifies inter-service communication

### 8. **Manual Approval**
- Pipeline pauses
- Requires human approval to proceed to production
- Click "Proceed" or "Abort"

### 9. **Deploy to Production**
- Rolling update: gradually replaces old pods
- Zero downtime deployment
- Waits for rollout completion

### 10. **Health Check**
- Verifies all services are healthy
- Collects metrics
- Sends notification

---

## Troubleshooting

### Issue: Pipeline won't start

**Solution:** 
```bash
# Check Jenkins logs
docker logs microservices-jenkins

# Verify webhook in GitHub
# Go to repo → Settings → Webhooks
# Check "Recent Deliveries" for errors
```

### Issue: Docker build fails

**Solution:**
```bash
# Check Docker daemon
docker ps

# Grant Jenkins Docker permissions
sudo usermod -aG docker jenkins

# Restart Jenkins
docker restart microservices-jenkins
```

### Issue: AKS deployment fails

**Solution:**
```bash
# Verify kubeconfig is valid
kubectl cluster-info --kubeconfig=/path/to/kubeconfig.yaml

# Check AKS credentials in Jenkins
# Manage Jenkins → Manage Credentials → aks-kubeconfig
```

### Issue: Manual approval not appearing

**Solution:**
- Check pipeline runs only on `main` branch
- Both `manual approval` and `deploy prod` stages have `when { branch 'main' }`

### Issue: Images not pushing to ACR

**Solution:**
```bash
# Verify ACR credentials
az acr login --name gauravcontainerreg

# Check image tag format
# Should be: gauravcontainerreg.azurecr.io/auth-service:latest

# Manually push to verify
docker tag auth-service:latest gauravcontainerreg.azurecr.io/auth-service:latest
docker push gauravcontainerreg.azurecr.io/auth-service:latest
```

---

## Best Practices

### 1. **Use Environment Variables**
```groovy
environment {
    REGISTRY = 'myregistry.azurecr.io'
    NAMESPACE = 'microservices'
}
```

### 2. **Keep Jenkinsfile in Version Control**
- Store `Jenkinsfile` in repository root
- Makes CI config part of code
- Easy to review and track changes

### 3. **Tag Docker Images Properly**
```
Format: registry/service:version
Example: myregistry.azurecr.io/auth-service:build-123-abc456
Also tag as latest: myregistry.azurecr.io/auth-service:latest
```

### 4. **Implement Security Scanning**
- Scan images for vulnerabilities (Trivy)
- Fail build on critical vulnerabilities
- Regular dependency updates

### 5. **Use Staging Before Production**
- Always test in staging first
- Run integration tests
- Manual approval before production

### 6. **Monitor Pipeline Health**
- Track build success rate
- Monitor deployment times
- Set up alerts for failures

### 7. **Log Everything**
- All pipeline steps are logged
- Logs are stored in Jenkins
- Setup centralized logging for production

### 8. **Use Credentials Hierarchy**
```
Global Credentials (System-wide)
  ├── GitHub token
  ├── Docker registry
  └── AKS kubeconfig
```

### 9. **Parallel Stages for Speed**
```groovy
parallel(
    'Build': { sh 'docker build ...' },
    'Test': { sh 'npm test' },
    'Scan': { sh 'trivy scan' }
)
```

### 10. **Notification & Alerting**
Send notifications to Slack, email, etc. on:
- Build success
- Build failure
- Deployment complete
- Critical errors

---

## Advanced Features

### Code Quality with SonarQube

```groovy
stage('Code Quality') {
    steps {
        sh '''
            docker run --rm -v $(pwd):/src \
            sonarsource/sonar-scanner-cli \
            -Dsonar.projectKey=microservices \
            -Dsonar.sources=/src \
            -Dsonar.host.url=http://sonarqube:9000
        '''
    }
}
```

### Performance Testing

```groovy
stage('Performance Test') {
    steps {
        sh '''
            docker run --rm grafana/k6 run \
            -e API_BASE_URL=http://staging-api \
            -e REQUESTS_PER_SECOND=100 \
            performance-test.js
        '''
    }
}
```

### Canary Deployments

Deploy to 10% of traffic first, then gradually increase.

```groovy
// Deploy to 10% of replicas
kubectl set replicas deployment/auth-service=1 -n production
// Monitor for issues
sleep 300
// If OK, scale to 100%
kubectl set replicas deployment/auth-service=2 -n production
```

---

## Next Steps

1. ✅ Install Jenkins
2. ✅ Configure credentials
3. ✅ Create pipeline job
4. ✅ Set up GitHub webhook
5. ✅ Push code to trigger pipeline
6. ✅ Monitor first build
7. ✅ Approve production deployment
8. ✅ View live application

---

## References

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkinsfile Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Pipeline Examples](https://www.jenkins.io/doc/pipeline/tour/overview/)
- [Blue Ocean](https://www.jenkins.io/doc/book/blueocean/)
