# GitHub Actions - Secrets Setup Guide

## 🔐 What Are Secrets?

Secrets are encrypted values stored in GitHub that:
- ✅ Only available in your workflows
- ✅ Never visible in logs
- ✅ GitHub encrypts them
- ✅ Can only be used by you in your repo

Example: Your SSH private key is a secret
- ❌ Never put `ssh_key: "-----BEGIN..."` in code
- ✅ Put in GitHub Secrets, reference with `${{ secrets.DEPLOY_KEY }}`

---

## Method 1: GitHub CLI (Fastest)

```bash
# 1. Login to GitHub
gh auth login

# 2. Add DEPLOY_HOST
gh secret set DEPLOY_HOST --body "your-ip.com"

# 3. Add DEPLOY_USER  
gh secret set DEPLOY_USER --body "ubuntu"

# 4. Add DEPLOY_KEY (your SSH private key)
gh secret set DEPLOY_KEY --body "$(cat ~/.ssh/id_rsa)"

# 5. Verify they were added
gh secret list
```

---

## Method 2: GitHub Web UI

### Step 1: Navigate to Secrets

```
1. Go to your GitHub repo
2. Click: Settings (top right, after Code tab)
3. Left sidebar: Click "Secrets and variables"
4. Click: "Actions"
5. Button: "New repository secret"
```

**Screenshot location:**
```
GitHub.com/yourname/microservices-project
           ↓
     Settings tab
           ↓
  Secrets and variables
           ↓
       Actions
```

### Step 2: Add DEPLOY_HOST

```
Secret name: DEPLOY_HOST

Value: (your server IP or domain)
       Examples:
       - 12.34.56.78
       - your-domain.com
       - ec2-12-34-56-78.compute.amazonaws.com

Click: "Add secret"
```

### Step 3: Add DEPLOY_USER

```
Secret name: DEPLOY_USER

Value: (SSH username)
       Examples:
       - ubuntu (most common)
       - ec2-user (AWS)
       - root
       - admin

Click: "Add secret"
```

### Step 4: Add DEPLOY_KEY

```
Secret name: DEPLOY_KEY

Value: (Your SSH private key - the entire content)

How to get:
1. Open terminal on your computer
2. Run: cat ~/.ssh/id_rsa
3. Copy entire output including:
   -----BEGIN OPENSSH PRIVATE KEY-----
   (your key)
   -----END OPENSSH PRIVATE KEY-----

Click: "Add secret"
```

If you don't have SSH key:
```bash
# Generate new SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
# Press Enter for all prompts (keep default)

# Then view it
cat ~/.ssh/id_rsa
```

### Step 5: Optional - Add SLACK_WEBHOOK

```
Secret name: SLACK_WEBHOOK

Value: (Your Slack incoming webhook URL)

How to get:
1. Go to: https://api.slack.com/apps
2. Create New App → From scratch
3. Name: microservices-cicd
4. For: Your workspace
5. Left sidebar: Click "Incoming Webhooks"
6. Toggle "Activate Incoming Webhooks" ON
7. Button: "Add New Webhook to Workspace"
8. Select channel: #deployments (or any channel)
9. Copy the URL
10. Paste in GitHub secret

This is optional - skip if you don't use Slack
```

---

## Verify Secrets Were Added

### Using GitHub CLI

```bash
gh secret list
# Shows all your secrets (without revealing values)
```

### Using GitHub Web UI

```
1. Go to: Repository Settings
2. Click: Secrets and variables → Actions
3. Should see:
   - DEPLOY_HOST
   - DEPLOY_USER
   - DEPLOY_KEY
   - (SLACK_WEBHOOK if added)
```

---

## Secrets Reference Table

| Secret | Value | Visibility | Security |
|--------|-------|------------|----------|
| DEPLOY_HOST | `your-ip.com` | Public | Low - it's your IP |
| DEPLOY_USER | `ubuntu` | Public | Low - could be guessed |
| DEPLOY_KEY | SSH private key | 🔴 SECRET | High - never share! |
| SLACK_WEBHOOK | `https://hooks...` | 🔴 SECRET | High - never share! |
| GITHUB_TOKEN | Auto provided | Auto | Auto provided |

---

## How Secrets Are Used in Workflow

In `.github/workflows/ci-cd.yml`:

```yaml
- name: Deploy to server
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.DEPLOY_HOST }}
    username: ${{ secrets.DEPLOY_USER }}
    key: ${{ secrets.DEPLOY_KEY }}
    script: |
      cd /app/microservices-project
      docker compose pull
      docker compose up -d
```

The `${{ secrets.DEPLOY_HOST }}` gets replaced with your actual value, but:
- ✅ The actual value is never displayed in logs
- ✅ It's encrypted in GitHub
- ✅ Only available during workflow execution

---

## Security Best Practices

### ✅ DO

- ✅ Keep SSH private key secure
- ✅ Rotate keys periodically
- ✅ Use different keys for different servers
- ✅ Restrict secret access to specific branches
- ✅ Audit who accessed secrets

### ❌ DON'T

- ❌ Share secret values
- ❌ Commit secrets to code
- ❌ Post secrets in Slack/email
- ❌ Use same key for dev and production
- ❌ Hardcode passwords

---

## If You Accidentally Exposed a Secret

**If you committed a secret to GitHub:**

```bash
# 1. Immediately rotate the secret
# For SSH keys:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
# Add new public key to your server
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@your-ip

# 2. Update GitHub secret with new key
gh secret set DEPLOY_KEY --body "$(cat ~/.ssh/id_rsa)"

# 3. Remove secret from git history
git-filter-repo --invert-paths --path <filename>
git push origin --force-with-lease
```

---

## Troubleshooting

### "Secret not working in workflow"

**Possible causes:**
1. Secret name typo - must match exactly
2. Workflow file syntax error
3. Secret not committed to repo yet
4. Using wrong branch

**Solution:**
```bash
# Check secret exists
gh secret list

# Check workflow syntax
# Look for: ${{ secrets.DEPLOY_HOST }}

# Make sure on main branch
git branch

# Re-run workflow
gh run list
```

### "Can't log in with SSH key"

**Possible causes:**
1. Public key not on server
2. SSH key format wrong
3. Permissions issue
4. Key doesn't match public key

**Solution:**
```bash
# Add public key to server
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@your-ip

# Or manually:
# SSH to server and add key:
cat >> ~/.ssh/authorized_keys << EOF
ssh-rsa ABC123... (your key)
EOF

# Check permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### "Secret shows as asterisks in logs"

**This is normal and expected!** ✅

GitHub automatically masks secrets in logs:
```
- Sending SSH key: *** (secret is masked)
```

This is a security feature.

---

## Different Types of Deployments

### VPS Deployment (What You're Using)

Secrets needed:
- ✅ DEPLOY_HOST
- ✅ DEPLOY_USER
- ✅ DEPLOY_KEY

### Kubernetes Deployment

Secrets needed:
- ✅ KUBECONFIG (k8s config file)
- ✅ DOCKER_USERNAME
- ✅ DOCKER_PASSWORD

### Docker Hub Upload

Secrets needed:
- ✅ DOCKER_USERNAME
- ✅ DOCKER_PASSWORD

### AWS Deployment

Secrets needed:
- ✅ AWS_ACCESS_KEY_ID
- ✅ AWS_SECRET_ACCESS_KEY
- ✅ AWS_REGION

---

## Environment Variables vs Secrets

### Secrets (Encrypted, Hidden)
```yaml
- name: Deploy
  with:
    password: ${{ secrets.DEPLOY_KEY }}  # Hidden in logs
```

Use for:
- Passwords
- API keys
- Auth tokens
- SSH keys

### Environment Variables (Visible in logs)
```yaml
- name: Build
  env:
    NODE_ENV: production  # Visible
```

Use for:
- Deployment target
- Config values
- Feature flags

---

## Common Secret Values

**SSH Key Format:**
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUtbm9uZS1ub25lAAAAAA...
-----END OPENSSH PRIVATE KEY-----
(exactly as shown in ~/.ssh/id_rsa)
```

**GitHub Personal Access Token:**
```
ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
(create at: github.com/settings/tokens)
```

**Docker Hub Token:**
```
dckr_pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
(create at: hub.docker.com/settings/security)
```

**Slack Webhook:**
```
https://hooks.slack.com/services/TXXX/BXXX/xxxxxxxxxxxx
(create at: api.slack.com/apps)
```

---

## Step-by-Step Setup Checklist

- [ ] Generate SSH key: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa`
- [ ] Add public key to server: `ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@your-ip`
- [ ] Test SSH works: `ssh ubuntu@your-ip` (no password)
- [ ] Go to GitHub Repo
- [ ] Click Settings → Secrets and variables → Actions
- [ ] Add secret: DEPLOY_HOST = your-ip
- [ ] Add secret: DEPLOY_USER = ubuntu
- [ ] Add secret: DEPLOY_KEY = (cat ~/.ssh/id_rsa)
- [ ] Add secret: SLACK_WEBHOOK = (optional)
- [ ] Verify: gh secret list
- [ ] Run: git commit -m "Add CI/CD" && git push
- [ ] Check: Repository → Actions tab
- [ ] Wait: ~20 minutes for first deployment
- [ ] Verify: http://your-ip:3000

---

## Quick Secret Setup Script

```bash
#!/bin/bash

# Interactive secret setup
echo "GitHub Actions Secrets Setup"
echo ""

read -p "Server IP/Domain (DEPLOY_HOST): " DEPLOY_HOST
read -p "SSH Username (DEPLOY_USER) [ubuntu]: " DEPLOY_USER
DEPLOY_USER=${DEPLOY_USER:-ubuntu}
read -p "SSH Key Path [~/.ssh/id_rsa]: " SSH_KEY_PATH
SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_rsa}

# Add secrets
gh secret set DEPLOY_HOST --body "$DEPLOY_HOST"
gh secret set DEPLOY_USER --body "$DEPLOY_USER"
gh secret set DEPLOY_KEY --body "$(cat $SSH_KEY_PATH)"

# Verify
gh secret list

echo ""
echo "✅ Secrets added successfully!"
```

Save as `setup-secrets.sh`, run with `bash setup-secrets.sh`

---

## Visual Summary

```
Your SSH Key (Local Machine)
  ├─ Private: ~/.ssh/id_rsa ← DEPLOY_KEY (secret)
  └─ Public: ~/.ssh/id_rsa.pub → Server ~/.ssh/authorized_keys

GitHub Secrets (Encrypted)
  ├─ DEPLOY_HOST: your-ip.com
  ├─ DEPLOY_USER: ubuntu
  └─ DEPLOY_KEY: -----BEGIN...

Workflow (Uses Secrets)
  ├─ SSH to DEPLOY_HOST
  ├─ Login as DEPLOY_USER
  ├─ Authenticate with DEPLOY_KEY
  └─ Run docker-compose commands

Your Server
  ├─ Receives SSH connection
  ├─ Verifies DEPLOY_KEY matches public key
  └─ Deploys application
```

---

## Success Indication

Workflow runs successfully when:

```
✅ Secrets added to GitHub
✅ Workflow file in .github/workflows/ci-cd.yml
✅ Push to main branch triggered workflow
✅ Build jobs run
✅ Test jobs run
✅ Deploy job runs without "SSH authentication failed"
✅ Containers start on your server
✅ App accessible at http://your-ip:3000
```

---

## Support

If stuck:
1. Check `GITHUB_ACTIONS_QUICK_REFERENCE.md`
2. Check `docs/GITHUB_ACTIONS_GUIDE.md`
3. View workflow logs: Repository → Actions
4. Test SSH manually: `ssh ubuntu@your-ip`
5. Check secrets exist: `gh secret list`

---

**You're ready to set up secrets! 🔐**
