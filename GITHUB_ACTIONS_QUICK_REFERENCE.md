# GitHub Actions CI/CD - Quick Reference

## 🔑 Secrets You Need

Add these secrets to: **Repository → Settings → Secrets and variables → Actions**

### Required Secrets (for deployment)

| Secret Name | Value | How to Get |
|-----------|-------|-----------|
| `DEPLOY_HOST` | Your server IP or domain | `your-server-ip.com` |
| `DEPLOY_USER` | SSH username | `ubuntu` |
| `DEPLOY_KEY` | SSH private key content | `cat ~/.ssh/id_rsa` |

### Optional Secrets (for notifications)

| Secret Name | Value | How to Get |
|-----------|-------|-----------|
| `SLACK_WEBHOOK` | Slack webhook URL | [Slack API](https://api.slack.com/apps) |

---

## Step-by-Step Setup

### Step 1: Add Secrets to GitHub (5 min)

```bash
# Using GitHub CLI (easiest)
gh auth login
gh secret set DEPLOY_HOST --body "your-ip.com"
gh secret set DEPLOY_USER --body "ubuntu"
gh secret set DEPLOY_KEY --body "$(cat ~/.ssh/id_rsa)"
```

Or manually via GitHub UI:
1. Go to **Repository → Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Add each secret above

### Step 2: Setup Your Server (15 min)

```bash
# On your server (ssh ubuntu@your-ip)

# 1. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Add user to docker group
sudo usermod -aG docker ubuntu

# 3. Create app directory
mkdir -p /app/microservices-project
cd /app/microservices-project

# 4. Clone repo
git clone https://github.com/yourusername/microservices-project.git .

# 5. Copy production docker-compose
mv docker-compose.prod.yml docker-compose.yml

# 6. Replace your GitHub username in the file
sed -i 's/$YOUR_GITHUB_USERNAME/yourusername/g' docker-compose.yml

# 7. Login to GitHub Container Registry
docker login ghcr.io
# (use your GitHub username and personal access token)
```

### Step 3: Add SSH Public Key to Server (2 min)

```bash
# On your local machine
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@your-server-ip
```

### Step 4: Push Code to Trigger Pipeline (1 min)

```bash
# Make a change
echo "# Updated" >> README.md

# Push to main
git add .
git commit -m "Trigger CI/CD pipeline"
git push origin main
```

### Step 5: Monitor Pipeline (Real-time)

```bash
# View pipeline runs
gh run list

# Watch logs live
gh run watch

# Or check GitHub UI: Your-Repo → Actions
```

---

## Pipeline Workflow

```
Your Commit
    ↓
GitHub detects push
    ↓
Triggers workflow (.github/workflows/ci-cd.yml)
    ↓
Build 4 Docker images
    ↓
Run tests
    ↓
Scan for vulnerabilities
    ↓
Push images to ghcr.io (GitHub Container Registry)
    ↓
SSH into your server
    ↓
Stop old containers
    ↓
Pull latest images
    ↓
Start new containers
    ↓
Verify services are healthy
    ↓
Send notification (Slack)
    ↓
✅ DONE - App updated!
```

---

## What Each Secret Does

### DEPLOY_HOST
- **Used by:** GitHub Actions workflow
- **What it does:** Tells GitHub where to SSH
- **Example:** `your-server.com` or `12.34.56.78`
- **Never share:** This is your server address

### DEPLOY_USER
- **Used by:** GitHub Actions workflow  
- **What it does:** The SSH user to log in as
- **Example:** `ubuntu`, `ec2-user`, `root`
- **Never share:** Could be used to access your server

### DEPLOY_KEY
- **Used by:** GitHub Actions workflow
- **What it does:** Private SSH key for authentication
- **Example:** Entire contents of `~/.ssh/id_rsa`
- **Never share:** This is a private key!
- **Protection:** GitHub encrypts it automatically

### SLACK_WEBHOOK (Optional)
- **Used by:** GitHub Actions workflow
- **What it does:** Sends deployment notifications to Slack
- **Example:** `https://hooks.slack.com/services/XXX/YYY/ZZZ`
- **Optional:** You can skip this if you don't use Slack

### GITHUB_TOKEN (Auto)
- **Used by:** GitHub Actions workflow
- **What it does:** Pushes images to GitHub Container Registry
- **Provided by:** GitHub automatically
- **No setup needed:** Just works!

---

## Generate SSH Key (if you don't have one)

```bash
# Generate new SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# This creates two files:
# ~/.ssh/id_rsa (private key - KEEP SECRET)
# ~/.ssh/id_rsa.pub (public key - SAFE TO SHARE)

# View your private key (to add to GitHub secret)
cat ~/.ssh/id_rsa
```

---

## Get Slack Webhook URL

1. Go to [Slack API Portal](https://api.slack.com/apps)
2. Click **Create New App**
3. Choose **From scratch**
4. Name: `microservices-cicd`
5. Select your workspace
6. Go to **Incoming Webhooks** (left sidebar)
7. Click **Add New Webhook to Workspace**
8. Select channel: `#deployments` or any channel
9. Copy the **Webhook URL**
10. In GitHub: Add secret `SLACK_WEBHOOK` with this URL

---

## Troubleshooting

### Pipeline doesn't start
- Check branch is `main` or `develop`
- Check workflow file: `.github/workflows/ci-cd.yml`
- Go to Actions tab → see any errors

### SSH deployment fails
- Check DEPLOY_HOST is correct: `your-server-ip.com`
- Check DEPLOY_USER is correct: usually `ubuntu`
- Check DEPLOY_KEY is your SSH private key
- Verify SSH access: `ssh -i ~/.ssh/id_rsa ubuntu@your-ip`

### Images not pushing
- GitHub Container Registry uses `GITHUB_TOKEN` automatically
- No setup needed for registry - just works!

### Deployment hangs
- Check server has Docker: `docker --version`
- Check server can pull images: `docker pull ghcr.io/yourusername/...`
- Check disk space: `df -h`

---

## What Gets Deployed

GitHub Actions automatically:

1. ✅ Builds 4 Docker images
   - auth-service
   - user-service  
   - product-service
   - frontend

2. ✅ Pushes to GitHub Container Registry
   - Tags: `latest` and `commit-hash`
   - Accessible as: `ghcr.io/yourusername/microservices-project/auth-service:latest`

3. ✅ Deploys to your server
   - Stops old containers
   - Pulls new images
   - Starts new containers with `docker compose up -d`

4. ✅ Verifies everything works
   - Checks health endpoints
   - Confirms services are running

---

## Environment Variables

The workflow provides these automatically:

```
GITHUB_ACTOR = your-username
GITHUB_SHA = commit-hash
GITHUB_REF = refs/heads/main
GITHUB_REPOSITORY = yourusername/microservices-project
```

---

## Free Limits

| Service | Free Quota | Cost if Exceeded |
|---------|-----------|-----------------|
| GitHub Actions | 2,000 min/month | $0.25/min after |
| Container Registry | 500 MB storage | $0.25 per GB/month |
| Workflows | Unlimited | - |

Your typical usage:
- 1 workflow per push = ~20 min
- 10 pushes per day = ~200 min/month
- Well under 2,000 min limit ✅

---

## Next Steps

1. ✅ Add secrets to GitHub
2. ✅ Setup server with Docker
3. ✅ Add SSH key to server
4. ✅ Push code to main branch
5. ✅ Monitor workflow in Actions tab
6. ✅ Verify app runs on server: `http://your-ip:3000`

---

## Common Commands

```bash
# View all secrets (don't show values)
gh secret list

# Test SSH connection to server
ssh -i ~/.ssh/id_rsa ubuntu@your-server-ip

# Check Docker on server
docker ps
docker compose logs

# Manually pull and start (for testing)
docker pull ghcr.io/yourusername/microservices-project/auth-service:latest
docker run -p 5001:5001 ghcr.io/yourusername/microservices-project/auth-service:latest

# View GitHub Actions logs
gh run list
gh run view RUN_ID --log
```

---

## Summary

**Total Setup Time:** ~30 minutes

**What You Get:**
- ✅ Automatic builds on every push
- ✅ Automatic tests
- ✅ Automatic security scans
- ✅ Automatic deployment to your server
- ✅ Zero downtime updates
- ✅ Slack notifications
- ✅ Free! (within GitHub limits)

**Three Secrets Required:**
- `DEPLOY_HOST` - Your server
- `DEPLOY_USER` - SSH user
- `DEPLOY_KEY` - SSH private key

**Let's Go!** 🚀
