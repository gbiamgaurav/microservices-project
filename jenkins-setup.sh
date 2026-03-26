#!/bin/bash

# Jenkins Setup Script
# This script automates Jenkins pipeline configuration

set -e

echo "================================"
echo "Jenkins Pipeline Setup"
echo "================================"
echo ""

# Check if Jenkins is running
if ! curl -s http://localhost:8080 > /dev/null; then
    echo "❌ Jenkins is not running at http://localhost:8080"
    echo ""
    echo "Start Jenkins with:"
    echo "  brew services start jenkins-lts"
    echo "  # or"
    echo "  docker run -d -p 8080:8080 jenkins/jenkins:lts"
    exit 1
fi

echo "✅ Jenkins is running"
echo ""

# Get Jenkins admin token
echo "📝 Getting Jenkins admin token..."
read -p "Enter your Jenkins admin username: " JENKINS_USER
read -sp "Enter your Jenkins password/token: " JENKINS_TOKEN
echo ""
echo ""

# Get GitHub token
echo "📝 GitHub Configuration"
read -p "Enter your GitHub repository URL: " GITHUB_REPO
read -p "Enter your GitHub personal access token: " GITHUB_TOKEN
echo ""

# Get Azure credentials
echo "📝 Azure Configuration"
read -p "Enter Azure Container Registry URL (e.g., gauravcontainerreg.azurecr.io): " ACR_URL
read -p "Enter ACR username: " ACR_USERNAME
read -sp "Enter ACR password: " ACR_PASSWORD
echo ""
echo ""

# Get AKS kubeconfig
echo "📝 AKS Configuration"
read -p "Enter AKS resource group: " AKS_RESOURCE_GROUP
read -p "Enter AKS cluster name: " AKS_CLUSTER_NAME
echo ""

echo "⏳ Fetching AKS kubeconfig..."
KUBECONFIG_PATH="/tmp/kubeconfig-${AKS_CLUSTER_NAME}.yaml"
az aks get-credentials \
    --resource-group ${AKS_RESOURCE_GROUP} \
    --name ${AKS_CLUSTER_NAME} \
    --file ${KUBECONFIG_PATH} > /dev/null

echo "✅ Kubeconfig saved to ${KUBECONFIG_PATH}"
echo ""

# Create Jenkins credentials via CLI
echo "🔑 Creating credentials in Jenkins..."

# 1. GitHub Token
curl -X POST "http://${JENKINS_USER}:${JENKINS_TOKEN}@localhost:8080/credentials/store/system/domain/_/createCredentials" \
  -F "json={
    'credentials': {
      'scope': 'GLOBAL',
      'id': 'github-token',
      'username': '${JENKINS_USER}',
      'password': '${GITHUB_TOKEN}',
      'description': 'GitHub Token',
      '\$class': 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
    }
  }" 2>/dev/null || echo "⚠️ GitHub credentials may need manual setup"

# 2. Docker Registry (ACR)
curl -X POST "http://${JENKINS_USER}:${JENKINS_TOKEN}@localhost:8080/credentials/store/system/domain/_/createCredentials" \
  -F "json={
    'credentials': {
      'scope': 'GLOBAL',
      'id': 'azure-acr-credentials',
      'username': '${ACR_USERNAME}',
      'password': '${ACR_PASSWORD}',
      'description': 'Azure Container Registry',
      '\$class': 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
    }
  }" 2>/dev/null || echo "⚠️ ACR credentials may need manual setup"

echo ""
echo "================================"
echo "✅ Jenkins Setup Complete!"
echo "================================"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Open Jenkins: http://localhost:8080"
echo ""
echo "2. Create New Pipeline Job:"
echo "   - Click 'New Item'"
echo "   - Name: 'microservices-pipeline'"
echo "   - Type: 'Pipeline'"
echo "   - Save"
echo ""
echo "3. Configure Pipeline:"
echo "   - GitHub Project URL: ${GITHUB_REPO}"
echo "   - Pipeline → Definition: Pipeline script from SCM"
echo "   - SCM: Git"
echo "   - Repository URL: ${GITHUB_REPO}"
echo "   - Credentials: github-token"
echo "   - Script Path: Jenkinsfile"
echo ""
echo "4. Add GitHub Webhook:"
echo "   - Go to: ${GITHUB_REPO}/settings/hooks"
echo "   - Add Webhook"
echo "   - Payload URL: http://YOUR_JENKINS_IP:8080/github-webhook/"
echo "   - Content type: application/json"
echo "   - Events: push"
echo ""
echo "5. Push code to trigger pipeline:"
echo "   git push origin main"
echo ""
echo "6. View pipeline: http://localhost:8080/blue/organizations/jenkins/microservices-pipeline/activity"
echo ""
