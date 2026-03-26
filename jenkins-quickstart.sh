#!/bin/bash

# Jenkins Quick Start Script
# One-command setup for CI/CD pipeline

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║       Jenkins CI/CD Pipeline Quick Start               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
echo ""

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    echo "Install with: brew install kubectl"
    exit 1
fi

if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed${NC}"
    echo "Install with: brew install azure-cli"
    exit 1
fi

echo -e "${GREEN}✅ Docker${NC}"
echo -e "${GREEN}✅ Docker Compose${NC}"
echo -e "${GREEN}✅ kubectl${NC}"
echo -e "${GREEN}✅ Azure CLI${NC}"
echo ""

# Get configuration
echo -e "${BLUE}📝 Configuration${NC}"
read -p "Enter Azure Resource Group: " AKS_RESOURCE_GROUP
read -p "Enter AKS Cluster Name: " AKS_CLUSTER_NAME
read -p "Enter ACR Name (e.g., gauravcontainerreg): " ACR_NAME
read -p "Enter GitHub Repository URL (HTTPS): " GITHUB_REPO

# Build ACR URL
ACR_URL="${ACR_NAME}.azurecr.io"

echo ""
echo -e "${BLUE}🚀 Starting Jenkins...${NC}"
echo ""

# Start Jenkins with Docker Compose
docker compose -f jenkins-compose.yml up -d

echo -e "${GREEN}✅ Jenkins started${NC}"
echo ""

# Wait for Jenkins to be ready
echo -e "${BLUE}⏳ Waiting for Jenkins to be ready... (this may take 30-60 seconds)${NC}"
max_attempts=60
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:8080/login > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Jenkins is ready${NC}"
        break
    fi
    echo -n "."
    sleep 1
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${RED}❌ Jenkins failed to start${NC}"
    exit 1
fi

echo ""
echo ""

# Get initial password
echo -e "${YELLOW}🔑 Initial Admin Password:${NC}"
INITIAL_PASS=$(docker compose -f jenkins-compose.yml exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
echo ""
echo -e "${BLUE}${INITIAL_PASS}${NC}"
echo ""
echo "Copy this password for the initial setup"
echo ""

# Create kubeconfig
echo -e "${BLUE}📦 Setting up AKS Kubeconfig...${NC}"
KUBECONFIG_PATH="/tmp/kubeconfig-${AKS_CLUSTER_NAME}.yaml"

az aks get-credentials \
    --resource-group ${AKS_RESOURCE_GROUP} \
    --name ${AKS_CLUSTER_NAME} \
    --file ${KUBECONFIG_PATH} > /dev/null 2>&1

echo -e "${GREEN}✅ Kubeconfig saved${NC}"
echo ""

# Display setup instructions
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              🎉 Setup Instructions                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}1️⃣  OPEN JENKINS${NC}"
echo "   URL: http://localhost:8080"
echo "   Username: admin"
echo "   Password: (paste the password above)"
echo ""

echo -e "${YELLOW}2️⃣  INSTALL PLUGINS${NC}"
echo "   - Install suggested plugins"
echo "   - After plugins install, install additional:"
echo "     • Docker Plugin"
echo "     • Kubernetes Plugin"
echo "     • GitHub Integration"
echo "     • Azure Credentials"
echo "     • Pipeline"
echo ""

echo -e "${YELLOW}3️⃣  ADD CREDENTIALS${NC}"
echo "   Manage Jenkins → Manage Credentials → Add:"
echo ""
echo "   a) GitHub Token"
echo "      - Kind: Secret text"
echo "      - Secret: Your GitHub personal access token"
echo "      - ID: github-token"
echo ""
echo "   b) Azure ACR"
echo "      - Kind: Username with password"
echo "      - Username: ACR username"
echo "      - Password: ACR password"
echo "      - ID: azure-acr-credentials"
echo ""
echo "   c) AKS Kubeconfig"
echo "      - Kind: Secret file"
echo "      - File: ${KUBECONFIG_PATH}"
echo "      - ID: aks-kubeconfig"
echo ""

echo -e "${YELLOW}4️⃣  CREATE PIPELINE${NC}"
echo "   - New Item → pipeline-name"
echo "   - Type: Pipeline"
echo "   - Pipeline → Pipeline script from SCM"
echo "   - SCM: Git"
echo "   - Repository: ${GITHUB_REPO}"
echo "   - Credentials: github-token"
echo "   - Script Path: Jenkinsfile"
echo ""

echo -e "${YELLOW}5️⃣  SETUP GITHUB WEBHOOK${NC}"
echo "   - Go to: ${GITHUB_REPO}/settings/hooks"
echo "   - Add webhook"
echo "   - Payload URL: http://localhost:8080/github-webhook/"
echo "   - Content type: application/json"
echo "   - Events: Push"
echo ""

echo -e "${YELLOW}6️⃣  TEST PIPELINE${NC}"
echo "   - Make a change in your code"
echo "   - Push to main branch"
echo "   - Pipeline should trigger automatically"
echo ""

echo -e "${YELLOW}7️⃣  VIEW PIPELINE${NC}"
echo "   - Jenkins Dashboard: http://localhost:8080"
echo "   - Blue Ocean (better UI): http://localhost:8080/blue"
echo ""

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              📚 Documentation                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Read full guide: docs/JENKINS_GUIDE.md"
echo ""

# Optional: Open Jenkins in browser
read -p "Open Jenkins in browser now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open http://localhost:8080
fi

echo ""
echo -e "${GREEN}✅ Jenkins is ready!${NC}"
echo ""
echo "🎯 Next: Complete the 7 setup instructions above"
echo ""
