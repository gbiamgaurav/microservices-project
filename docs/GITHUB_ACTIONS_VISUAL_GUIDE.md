# GitHub Actions CI/CD - Visual Guide

## Complete Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    YOUR GITHUB REPOSITORY                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─ Code Files                                                               │
│  ├─ microservices/auth-service/                                              │
│  ├─ microservices/user-service/                                              │
│  ├─ microservices/product-service/                                           │
│  ├─ frontend/                                                                │
│  ├─ docker-compose.yml                                                       │
│  └─ .github/workflows/ci-cd.yml  ← WORKFLOW FILE                             │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
                          Developer Push Commit
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│               GITHUB ACTIONS (Automated CI/CD)                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  Step 1: CHECKED OUT                                                         │
│  ├─ Clone repo into GitHub Actions runner (virtual machine)                  │
│  └─ Ready to build                                                           │
│                                                                               │
│  Step 2: BUILD (4 Docker Images)                                             │
│  ├─ Build auth-service:latest → ghcr.io/youruser/auth-service:latest       │
│  ├─ Build user-service:latest → ghcr.io/youruser/user-service:latest       │
│  ├─ Build product-service:latest → ghcr.io/youruser/product-service:latest │
│  └─ Build frontend:latest → ghcr.io/youruser/frontend:latest               │
│                                                                               │
│  Step 3: TESTS                                                               │
│  ├─ Run Python unit tests                                                    │
│  └─ Fail build if tests fail                                                 │
│                                                                               │
│  Step 4: SECURITY SCAN                                                       │
│  ├─ Scan images with Trivy                                                   │
│  └─ Flag vulnerabilities                                                     │
│                                                                               │
│  Step 5: PUSH TO REGISTRY                                                    │
│  ├─ Push to GitHub Container Registry (ghcr.io)                             │
│  ├─ Tag: latest                                                              │
│  └─ Tag: commit-hash                                                         │
│                                                                               │
│  Step 6: DEPLOY TO SERVER                                                    │
│  ├─ SSH into your server                                                     │
│  ├─ Pull latest images from registry                                         │
│  ├─ Stop old containers                                                      │
│  ├─ Start new containers                                                     │
│  └─ Verify health checks pass                                                │
│                                                                               │
│  Step 7: NOTIFY                                                              │
│  └─ Send Slack message: ✅ Deployment successful                            │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│            GITHUB CONTAINER REGISTRY (ghcr.io)                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ghcr.io/yourusername/microservices-project/
│  ├─ auth-service:latest
│  ├─ auth-service:abc1234
│  ├─ user-service:latest
│  ├─ user-service:abc1234
│  ├─ product-service:latest
│  ├─ product-service:abc1234
│  ├─ frontend:latest
│  └─ frontend:abc1234
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                    YOUR SERVER / VPS                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  Ubuntu 22.04 (EC2 / DigitalOcean / Linode / Custom VPS)                    │
│                                                                               │
│  Docker Compose Running                                                      │
│  ├─ auth-service:latest          (Port 5001)                                 │
│  ├─ user-service:latest          (Port 5002)                                 │
│  ├─ product-service:latest       (Port 5003)                                 │
│  └─ frontend:latest              (Port 3000)                                 │
│                                                                               │
│  External Access:                                                            │
│  └─ http://your-server-ip:3000   ← Your app!                               │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Timeline: Push to Live

```
00:00 - Developer pushes to main branch
        └─ git push origin main

00:05 - GitHub Actions workflow starts
        └─ Build 4 Docker images

05:30 - Images built, tests running
        └─ Unit tests execute

07:00 - Tests complete, security scan starts
        └─ Trivy scanning for vulnerabilities

09:30 - Security scan complete
        └─ Images pushed to GitHub Container Registry

10:15 - Deploy starts
        ├─ SSH into your server
        ├─ Pull latest images
        ├─ Stop old containers
        └─ Start new containers

11:30 - Deployment complete!
        ├─ Health checks pass
        ├─ All services running
        └─ Slack notification sent

TOTAL TIME: 11.5 minutes
STATUS: ✅ YOUR APP IS LIVE WITH NEW CHANGES
```

---

## Secrets Flow

```
┌────────────────────────────────┐
│   GitHub Repository Secrets    │
├────────────────────────────────┤
│                                │
│  DEPLOY_HOST = 12.34.56.78    │
│  DEPLOY_USER = ubuntu         │
│  DEPLOY_KEY = -----BEGIN...    │ (SSH private key)
│  SLACK_WEBHOOK = https://...  │
│                                │
└────────────────────────────────┘
       (Encrypted by GitHub)
              ↓
┌────────────────────────────────┐
│  GitHub Actions Workflow       │
├────────────────────────────────┤
│                                │
│  Access in steps:              │
│  ${{ secrets.DEPLOY_HOST }}   │
│  ${{ secrets.DEPLOY_USER }}   │
│  ${{ secrets.DEPLOY_KEY }}    │
│                                │
└────────────────────────────────┘
       (Only available in runner)
              ↓
┌────────────────────────────────┐
│  SSH Deployment Step           │
├────────────────────────────────┤
│                                │
│  1. Use DEPLOY_KEY to auth     │
│  2. SSH into DEPLOY_HOST       │
│  3. As DEPLOY_USER             │
│  4. Pull & run containers      │
│                                │
└────────────────────────────────┘
```

---

## Comparing Setup Options

```
┌─────────────────────────────────────────────────────────────────────┐
│       SETUP OPTIONS: GitHub Only vs Jenkins vs Kubernetes           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  GITHUB ACTIONS (✅ RECOMMENDED FOR YOU)                           │
│  ├─ Setup time: 30 minutes                                         │
│  ├─ Cost: Free (2000 min/month included)                          │
│  ├─ Effort: Easy - mostly clicks                                   │
│  ├─ Deployment: To your own server (VPS)                           │
│  └─ Best for: Simple, fast, GitHub-based workflows                │
│                                                                      │
│  JENKINS                                                            │
│  ├─ Setup time: 2-3 hours                                          │
│  ├─ Cost: Free (self-hosted)                                       │
│  ├─ Effort: Medium - config files & plugins                        │
│  ├─ Deployment: To any server (VPS, K8s, etc)                      │
│  └─ Best for: Complex workflows, enterprise                        │
│                                                                      │
│  KUBERNETES + AKS (Azure)                                          │
│  ├─ Setup time: 4-6 hours                                          │
│  ├─ Cost: $600+/month                                              │
│  ├─ Effort: Hard - cloud infrastructure                            │
│  ├─ Deployment: Managed Kubernetes cluster                         │
│  └─ Best for: Large scale, high availability                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
microservices-project/
│
├─ .github/
│  └─ workflows/
│     └─ ci-cd.yml                    ← Workflow configuration
│
├─ microservices/
│  ├─ auth-service/
│  ├─ user-service/
│  └─ product-service/
│
├─ frontend/
│
├─ docker-compose.yml                 ← For local development
├─ docker-compose.prod.yml            ← For server deployment
│
├─ docs/
│  ├─ GITHUB_ACTIONS_GUIDE.md         ← Full guide
│  └─ (other docs)
│
├─ GITHUB_ACTIONS_QUICK_REFERENCE.md  ← Cheat sheet
│
└─ github-actions-setup.sh            ← Setup script
```

---

## What GitHub Actions Can Do

✅ **Supported**
- Build Docker images
- Run tests
- Push to registries (Docker Hub, GitHub, ECR, etc)
- Deploy to servers (SSH)
- Deploy to Kubernetes (kubectl)
- Deploy to cloud platforms (AWS, Azure, GCP)
- Send notifications (Slack, email, Discord)
- Run custom scripts
- Parallel jobs

❌ **Not Supported**
- GPU workloads (GitHub runners have CPU only)
- Very large builds (max 6 hours per job)
- High memory builds (max 7 GB RAM)

---

## Example Workflow

```yaml
# Simplified workflow showing main concepts

name: Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # 1. Get code
      - uses: actions/checkout@v4
      
      # 2. Build image
      - run: docker build -t myimage .
      
      # 3. Login to registry using secret
      - run: docker login -u ${{ github.actor }} -p ${{ secrets.GITHUB_TOKEN }} ghcr.io
      
      # 4. Push image
      - run: docker push ghcr.io/user/myimage:latest
      
      # 5. Deploy using secret
      - uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_KEY }}
          script: |
            docker pull ghcr.io/user/myimage:latest
            docker compose up -d
```

---

## Failure Scenarios

```
┌─ Build Fails (Docker build error)
│  └─ Status: ❌ RED
│  └─ Action: Fix Dockerfile, push again
│
├─ Tests Fail
│  └─ Status: ❌ RED
│  └─ Action: Fix tests, push again
│
├─ Security Scan Fails
│  └─ Status: ⚠️ YELLOW
│  └─ Action: Fix vulnerabilities or ignore
│
├─ Image Push Fails
│  └─ Status: ❌ RED
│  └─ Action: Check GitHub token, registry access
│
└─ Deployment Fails
   └─ Status: ❌ RED
   └─ Reasons:
      ├─ SSH key invalid → Check DEPLOY_KEY secret
      ├─ Server down → Check DEPLOY_HOST IP
      ├─ No Docker → SSH and install Docker
      └─ Disk full → SSH and check disk space
```

---

## Success Indicators

```
✅ GitHub Actions shows GREEN checkmark
   ├─ Workflow: ci-cd.yml ✅
   └─ All jobs successful

✅ GitHub Container Registry has new images
   └─ ghcr.io/user/auth-service:latest (updated)

✅ Server has new containers running
   └─ docker compose ps shows recent start time

✅ App is accessible
   └─ http://your-server-ip:3000 loads

✅ Slack notification received (if configured)
   └─ "✅ Deployment Successful"
```

---

## Cost Breakdown

```
GitHub Actions (per month):
├─ Free: 2,000 minutes ✅
├─ Your usage: ~10 pushes × 20 min = ~200 min
└─ Total: Well within free tier

GitHub Container Registry:
├─ Free: 500 MB storage ✅
├─ Your images: ~1.5 GB total (~150 MB × 4 services)
├─ After: $0.25 per GB/month
└─ Total: Free tier sufficient or ~$0.50/month

Your VPS Server:
├─ Cost: $3-5/month (small VM)
├─ Provider: DigitalOcean, Linode, Vultr, AWS
└─ Total: $3-5/month

TOTAL MONTHLY COST: $3-5 🎉
```

---

## Quick Decision Tree

```
┌─ Do you have a GitHub repo?
│  ├─ YES → Use GitHub Actions ✅
│  └─ NO  → Create one first
│
├─ Do you have a server?
│  ├─ YES → Deploy to it via SSH ✅
│  ├─ NO  → Get a VPS ($3-5/month) ✅
│  └─ MAYBE → Use Railway.app or Render (free) ✅
│
├─ Do you need notifications?
│  ├─ YES → Add Slack webhook
│  └─ NO  → Skip it
│
└─ Done! You have CI/CD 🚀
```

---

## Estimated Setup Time

```
Task                          Time    Difficulty
────────────────────────────────────────────────
1. Add GitHub secrets         5 min   🟢 Easy
2. Setup server               10 min  🟢 Easy
3. Commit workflow file       2 min   🟢 Easy
4. First deployment           5 min   🟢 Easy
5. Monitor workflow           2 min   🟢 Easy
────────────────────────────────────────────────
TOTAL                         24 min  🟢 Easy
```

---

## Support & Help

| Issue | Check |
|-------|-------|
| Workflow won't start | `.github/workflows/ci-cd.yml` exists? Branch is `main`? |
| SSH fails | SSH key in secrets? Public key on server? IP correct? |
| Images won't push | GitHub token valid? Container registry enabled? |
| Deployment hangs | Server has Docker? Disk space? Network connection? |
| Slow builds | Normal (GitHub runner speed). First build slower. |

---

## Next: What You Can Do

After basic CI/CD works:

1. **Add database** (PostgreSQL)
2. **Add env variables** for different environments
3. **Add canary deployments** (deploy to 10% first)
4. **Add rollback capability** (go back to previous version)
5. **Add cost tracking** (see what GitHub charges)
6. **Scale to Kubernetes** (when you need it)

---

**You're ready to go! 🚀**
