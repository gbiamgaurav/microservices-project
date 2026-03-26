#!/bin/bash

# GitHub Actions Setup Script
# Configure GitHub Secrets for CI/CD

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║    GitHub Actions CI/CD Setup Script                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI is not installed${NC}"
    echo ""
    echo "Install it with:"
    echo "  brew install gh"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI found${NC}"
echo ""

# Check if logged in
if ! gh auth status > /dev/null 2>&1; then
    echo -e "${YELLOW}Login to GitHub first:${NC}"
    gh auth login
fi

echo ""
echo -e "${BLUE}📝 Configuration${NC}"
echo ""

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q)
echo -e "${GREEN}✅ Repository: ${REPO}${NC}"
echo ""

# Get deployment details
read -p "Enter server IP or domain (DEPLOY_HOST): " DEPLOY_HOST
read -p "Enter SSH username (DEPLOY_USER) [default: ubuntu]: " DEPLOY_USER
DEPLOY_USER=${DEPLOY_USER:-ubuntu}

# Ask about SSH key
read -p "Enter path to SSH private key [default: ~/.ssh/id_rsa]: " SSH_KEY_PATH
SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_rsa}

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${RED}❌ SSH key not found at $SSH_KEY_PATH${NC}"
    echo ""
    echo "Generate a new key:"
    echo "  ssh-keygen -t rsa -b 4096 -f $SSH_KEY_PATH"
    exit 1
fi

# Optional: Ask for Slack webhook
read -p "Enter Slack webhook URL (leave empty to skip): " SLACK_WEBHOOK

echo ""
echo -e "${BLUE}🔑 Adding GitHub Secrets${NC}"
echo ""

# Add secrets
echo "Adding DEPLOY_HOST..."
gh secret set DEPLOY_HOST --body "$DEPLOY_HOST"
echo -e "${GREEN}✅ DEPLOY_HOST added${NC}"

echo "Adding DEPLOY_USER..."
gh secret set DEPLOY_USER --body "$DEPLOY_USER"
echo -e "${GREEN}✅ DEPLOY_USER added${NC}"

echo "Adding DEPLOY_KEY..."
SSH_KEY_CONTENT=$(cat "$SSH_KEY_PATH")
gh secret set DEPLOY_KEY --body "$SSH_KEY_CONTENT"
echo -e "${GREEN}✅ DEPLOY_KEY added${NC}"

if [ ! -z "$SLACK_WEBHOOK" ]; then
    echo "Adding SLACK_WEBHOOK..."
    gh secret set SLACK_WEBHOOK --body "$SLACK_WEBHOOK"
    echo -e "${GREEN}✅ SLACK_WEBHOOK added${NC}"
fi

echo ""
echo -e "${BLUE}📋 Verifying Secrets${NC}"
echo ""

gh secret list

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ Setup Complete!                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}📝 Next Steps:${NC}"
echo ""
echo "1️⃣  Add public key to your server:"
echo "   ssh-copy-id -i ${SSH_KEY_PATH}.pub $DEPLOY_USER@$DEPLOY_HOST"
echo ""
echo "2️⃣  Setup server:"
echo "   ssh $DEPLOY_USER@$DEPLOY_HOST"
echo "   # Run these on server:"
echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
echo "   sudo sh get-docker.sh"
echo "   sudo usermod -aG docker $DEPLOY_USER"
echo "   mkdir -p /app && cd /app"
echo "   git clone https://github.com/${REPO}.git"
echo ""
echo "3️⃣  Commit and push code:"
echo "   git add .github/"
echo "   git commit -m 'Add GitHub Actions CI/CD'"
echo "   git push origin main"
echo ""
echo "4️⃣  Check workflow:"
echo "   GitHub → Actions → CI/CD Pipeline"
echo ""
echo "5️⃣  View logs:"
echo "   gh run list --limit 5"
echo "   gh run view RUN_ID --log"
echo ""

# Optional: Open GitHub Actions page
read -p "Open GitHub Actions page? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh repo view --web --web=https://github.com/${REPO}/actions
fi

echo ""
echo -e "${GREEN}✅ All done!${NC}"
echo ""
