# GitHub Actions CI/CD Guide

Complete guide to set up and use GitHub Actions for your microservices CI/CD pipeline.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Setup GitHub Secrets](#setup-github-secrets)
3. [Deployment Options](#deployment-options)
4. [How It Works](#how-it-works)
5. [Monitoring Pipeline](#monitoring-pipeline)
6. [Troubleshooting](#troubleshooting)

---

## Overview

**GitHub Actions** is GitHub's built-in CI/CD service. It:
- ✅ Builds Docker images automatically
- ✅ Runs tests
- ✅ Pushes to GitHub Container Registry (free)
- ✅ Deploys to your server
- ✅ Sends notifications
- ✅ **No external tools needed** - everything in GitHub

### Free Tiers

| Service | Free Quota |
|---------|-----------|
| **GitHub Actions** | 2,000 minutes/month |
| **GitHub Container Registry** | 500 MB free storage |
| **Workflows** | Unlimited |

---

## Setup GitHub Secrets

GitHub Secrets store sensitive data used in your workflow. They're encrypted and only available in your CI/CD pipeline.

### Option 1: Using GitHub UI

1. Go to **Repository Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each secret below

### Option 2: Using GitHub CLI

```bash
# Login to GitHub
gh auth login

# Add secrets
gh secret set SECRET_NAME --body "secret-value"
gh secret set DEPLOY_HOST --body "your.server.com"
gh secret set DEPLOY_USER --body "ubuntu"
```

---

## 🔑 Required Secrets

### For GitHub Container Registry (Recommended)

**Secret 1: GitHub Token (Auto-generated)**
- No setup needed! GitHub automatically provides `GITHUB_TOKEN`
- Used by: `github.token` in workflow

### For Slack Notifications (Optional)

**Secret 2: Slack Webhook URL**
```
Secret name: SLACK_WEBHOOK
Value: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

Get it:
1. Go to [Slack API](https://api.slack.com/apps)
2. Create new app
3. Enable Incoming Webhooks
4. Copy webhook URL

### For Deployment to Server

**Secret 3: Deploy Host**
```
Secret name: DEPLOY_HOST
Value: your-server-ip-or-domain.com
```

**Secret 4: Deploy User**
```
Secret name: DEPLOY_USER
Value: ubuntu
(or whatever SSH user you have)
```

**Secret 5: Deploy SSH Key**
```
Secret name: DEPLOY_KEY
Value: (contents of your private SSH key)
```

Get SSH key:
```bash
# On your local machine
cat ~/.ssh/id_rsa
# Copy entire output including -----BEGIN PRIVATE KEY-----
```

---

## Summary of All Secrets Needed

| Secret Name | Value | Optional? |
|-------------|-------|-----------|
| `DEPLOY_HOST` | Your server IP/domain | ❌ Required |
| `DEPLOY_USER` | SSH username | ❌ Required |
| `DEPLOY_KEY` | SSH private key | ❌ Required |
| `SLACK_WEBHOOK` | Slack webhook URL | ✅ Optional |
| `GITHUB_TOKEN` | Auto-provided | ✅ Auto |

---

## Deployment Options

### Option A: Deploy to VPS (Ubuntu Server)

**Best for:** Self-hosted servers, AWS EC2, DigitalOcean, etc.

#### Setup Server

1. **Install Docker & Docker Compose**
```bash
# SSH into your server
ssh ubuntu@your-server-ip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker ubuntu
```

2. **Clone your repository**
```bash
mkdir -p /app
cd /app
git clone https://github.com/yourusername/microservices-project.git
cd microservices-project
```

3. **Create docker-compose.yml for server**
```yaml
# Use ghcr.io images instead of local
version: '3.8'

services:
  auth-service:
    image: ghcr.io/yourusername/microservices-project/auth-service:latest
    ports:
      - "5001:5001"
    environment:
      - FLASK_ENV=production

  # ... similarly for other services
```

#### Add GitHub Secrets (VPS Method)

Go to Repo → Settings → Secrets → Add:

1. **DEPLOY_HOST** = `your-server-ip.com`
2. **DEPLOY_USER** = `ubuntu`
3. **DEPLOY_KEY** = Your SSH private key

The workflow will SSH into your server and:
- Pull latest code
- Stop old containers
- Pull latest images from GitHub Container Registry
- Start new containers with `docker compose up -d`

---

### Option B: Deploy to Railway.app (Easier, Free)

**Best for:** Simple deployments without managing servers

#### Railway Setup

1. Go to [Railway.app](https://railway.app)
2. Sign up with GitHub
3. Create new project
4. Connect GitHub repository
5. Railway auto-deploys on push!

**Pros:**
- ✅ No server management
- ✅ Auto SSL certificates
- ✅ Built-in monitoring
- ✅ Free tier available

**Cons:**
- ❌ Limited customization
- ❌ Paid for production

---

### Option C: Deploy to Render (Also Easy, Free)

**Best for:** Quick deployment without DevOps knowledge

#### Render Setup

1. Go to [Render.com](https://render.com)
2. Sign up with GitHub
3. Create new Web Service
4. Select GitHub repository
5. Configure environment
6. Render auto-deploys!

---

### Option D: Keep Using Docker Compose Locally

**Best for:** Development only

```bash
# Just run locally
docker compose up -d

# Access at http://localhost:3000
```

---

## How It Works

### Pipeline Flow

```
1. Push to GitHub (main branch)
   ↓
2. GitHub detects changes
   ↓
3. Triggers workflow in .github/workflows/ci-cd.yml
   ↓
4. CREATE RUNNER (Ubuntu Virtual Machine)
   ├─ Build Docker Images (4 images)
   │  ├─ Build auth-service
   │  ├─ Build user-service
   │  ├─ Build product-service
   │  └─ Build frontend
   │
   ├─ Push to GitHub Container Registry
   │  └─ Use GITHUB_TOKEN (auto)
   │
   ├─ Run Tests
   │  └─ Python unit tests
   │
   ├─ Security Scan
   │  └─ Trivy vulnerability scanner
   │
   └─ Deploy to Your Server (Optional)
      ├─ SSH into server
      ├─ Git pull latest
      ├─ Stop old containers
      ├─ Pull latest images
      └─ Start new containers
   ↓
5. Send Notification (Slack)
   ↓
6. Done! ✅
```

### Timeline

| Step | Time |
|------|------|
| Checkout | 10 sec |
| Build images | 5-10 min |
| Push to registry | 1-2 min |
| Run tests | 2-3 min |
| Security scan | 2-3 min |
| Deploy | 1-2 min |
| **TOTAL** | **~20 minutes** |

---

## Monitoring Pipeline

### View Pipeline Runs

1. Go to your GitHub repository
2. Click **Actions** tab
3. See all workflow runs

### View Real-time Logs

1. Click on a workflow run
2. Click on a job
3. See live logs as it runs

### Check Job Status

- 🟢 **Green** = Success
- 🔴 **Red** = Failed
- 🟡 **Yellow** = In progress

---

## Environment Variables

The workflow automatically provides:

```yaml
GITHUB_ACTOR: Your GitHub username
GITHUB_SHA: Commit hash
GITHUB_REF: Branch name (e.g., refs/heads/main)
GITHUB_REPOSITORY: owner/repo
```

Use in workflow:
```yaml
tags: |
  ${{ env.IMAGE_NAME }}:${{ github.sha }}
  ${{ env.IMAGE_NAME }}:latest
```

---

## Triggering Workflows

### Automatic Triggers

Pipeline runs when you:

```yaml
on:
  push:
    branches: [main, develop]  # Push to main or develop
    paths:                      # AND changes in these paths:
      - 'microservices/**'      # Changes in services
      - 'frontend/**'           # Changes in frontend
      - 'docker-compose.yml'    # Changes in compose file
  pull_request:
    branches: [main, develop]  # Also on pull requests
```

### Manual Trigger (Optional)

Add to workflow to allow manual trigger:

```yaml
on:
  workflow_dispatch:  # Will show "Run workflow" button
```

---

## Troubleshooting

### Issue: Workflow doesn't trigger

**Solution:**
- Check file path: `.github/workflows/ci-cd.yml`
- Verify branch is `main` or `develop`
- Check push is to files in `paths` filter
- Manually trigger: Actions → Workflow → Run workflow

### Issue: Docker images not building

**Solution:**
```bash
# Check Dockerfile paths
ls -la microservices/auth-service/Dockerfile
ls -la frontend/Dockerfile

# Test locally
docker build -f microservices/auth-service/Dockerfile .
```

### Issue: Deployment fails

**Solution:**

1. Check SSH access:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@your-server-ip
```

2. Verify SSH key is in GitHub Secrets (DEPLOY_KEY)

3. Check server has Docker:
```bash
# On server
docker --version
docker compose --version
```

4. View workflow logs:
- Go to Actions → Failed run → Deploy job
- Read error messages

### Issue: Images not pushing to registry

**Solution:**
- `GITHUB_TOKEN` is auto-provided, no setup needed
- But verify workflow has:
```yaml
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

---

## Security Best Practices

### 1. Never Commit Secrets
❌ Bad:
```yaml
password: "my-secret-password"  # EXPOSED!
```

✅ Good:
```yaml
password: ${{ secrets.MY_SECRET }}  # Hidden
```

### 2. Rotate SSH Keys Regularly
```bash
# Generate new SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Update GitHub secret: DEPLOY_KEY
```

### 3. Limit Secret Scope
- Use branch protection rules
- Require reviews before merge to main
- Only deploy main branch to production

### 4. Audit Secret Access
- GitHub logs all secret accesses
- Check Actions → Runs for who deployed when

---

## Sample Workflow Commands

### Run custom command on deploy

Edit `.github/workflows/ci-cd.yml`:

```yaml
- name: Custom deployment script
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.DEPLOY_HOST }}
    username: ${{ secrets.DEPLOY_USER }}
    key: ${{ secrets.DEPLOY_KEY }}
    script: |
      # Your custom commands
      cd /app/microservices-project
      docker compose logs auth-service
      curl http://localhost:5001/health
```

### Send email notification

Add step:

```yaml
- name: Email notification
  if: failure()
  uses: davisnetwork/action-mail@v1
  with:
    to: your-email@example.com
    subject: "Deployment failed!"
    body: "Build #${{ github.run_number }} failed"
```

---

## Quick Start Commands

### Setup (One-time)

```bash
# 1. Add workflow file (already done in .github/workflows/ci-cd.yml)

# 2. Create SSH key (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/deploy_key

# 3. Add public key to server
ssh-copy-id -i ~/.ssh/deploy_key.pub ubuntu@your-server-ip

# 4. Add secrets to GitHub (via UI or CLI)
gh secret set DEPLOY_HOST --body "your.server.com"
gh secret set DEPLOY_USER --body "ubuntu"
gh secret set DEPLOY_KEY --body "$(cat ~/.ssh/deploy_key)"

# 5. Push code to trigger

# 6. Check Actions tab on GitHub
```

### View Logs

```bash
# View locally (if using GitHub CLI)
gh run list --limit 5
gh run view RUN_ID --log
```

---

## Example Workflow Runs

### Successful Run

```
✅ Checkout code
✅ Build auth-service (2min 15sec)
✅ Build user-service (2min 10sec)
✅ Build product-service (2min 08sec)
✅ Build frontend (2min 30sec)
✅ Push to registry (45sec)
✅ Run tests (1min 20sec)
✅ Security scan (2min)
✅ Deploy (1min)
✅ Verify deployment
✅ Slack notification sent

TOTAL TIME: 18 minutes
STATUS: ✅ SUCCESS
```

### Failed Run

```
✅ Checkout code
✅ Build auth-service (2min 15sec)
✅ Build user-service (2min 10sec)
✅ Build product-service (2min 08sec)
✅ Build frontend (2min 30sec)
✅ Push to registry (45sec)
✅ Run tests (1min 20sec)
⚠️  Security scan (FOUND VULNERABILITIES)
❌ Deploy (skipped due to security issues)
❌ Slack failure notification sent

ACTION: Fix vulnerabilities and re-push
```

---

## Next Steps

1. ✅ Commit workflow file to `.github/workflows/ci-cd.yml`
2. ✅ Add GitHub Secrets (DEPLOY_HOST, DEPLOY_USER, DEPLOY_KEY)
3. ✅ Setup server (Docker + Docker Compose)
4. ✅ Test with `git push origin main`
5. ✅ Monitor Actions tab
6. ✅ Approve manual approval if needed
7. ✅ Verify deployment on server

---

## Comparison: GitHub Actions vs Jenkins

| Feature | GitHub Actions | Jenkins |
|---------|---|---|
| **Setup** | Click and done | Install, configure |
| **Cost** | Free (with limits) | Free (self-hosted) |
| **Learning curve** | Easy | Medium |
| **UI** | Beautiful | Functional |
| **Secrets** | Built-in | Plugin-based |
| **Triggers** | Event-based | Webhook |
| **Parallel jobs** | Yes | Yes |
| **Best for** | GitHub repos | Any repo |

---

## References

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)
