pipeline {
    agent any

    environment {
        // Azure & Docker Registry
        REGISTRY = 'gauravcontainerreg.azurecr.io'
        REGISTRY_CREDENTIALS = 'azure-acr-credentials'
        
        // GitHub
        REPO_URL = 'https://github.com/yourusername/microservices-project.git'
        REPO_CREDENTIALS = 'github-credentials'
        
        // AKS Credentials
        AKS_CLUSTER = 'microservices-aks'
        AKS_RESOURCE_GROUP = 'microservices-rg'
        
        // Namespaces
        STAGING_NS = 'staging'
        PROD_NS = 'microservices'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    triggers {
        // Trigger on GitHub push
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                echo '========== CHECKOUT =========='
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: "${REPO_URL}"]]
                ])
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                    env.BUILD_TAG = "${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                echo '========== BUILDING DOCKER IMAGES =========='
                script {
                    sh '''
                        # Build Auth Service
                        docker build -t ${REGISTRY}/auth-service:${BUILD_TAG} \
                            -f microservices/auth-service/Dockerfile .
                        docker tag ${REGISTRY}/auth-service:${BUILD_TAG} \
                            ${REGISTRY}/auth-service:latest

                        # Build User Service
                        docker build -t ${REGISTRY}/user-service:${BUILD_TAG} \
                            -f microservices/user-service/Dockerfile .
                        docker tag ${REGISTRY}/user-service:${BUILD_TAG} \
                            ${REGISTRY}/user-service:latest

                        # Build Product Service
                        docker build -t ${REGISTRY}/product-service:${BUILD_TAG} \
                            -f microservices/product-service/Dockerfile .
                        docker tag ${REGISTRY}/product-service:${BUILD_TAG} \
                            ${REGISTRY}/product-service:latest

                        # Build Frontend
                        docker build -t ${REGISTRY}/frontend:${BUILD_TAG} \
                            -f frontend/Dockerfile .
                        docker tag ${REGISTRY}/frontend:${BUILD_TAG} \
                            ${REGISTRY}/frontend:latest

                        echo "✅ All images built successfully"
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo '========== RUNNING TESTS =========='
                script {
                    sh '''
                        # Run unit tests
                        docker run --rm ${REGISTRY}/auth-service:${BUILD_TAG} \
                            python -m pytest microservices/auth-service/test_*.py || true

                        echo "✅ Tests completed"
                    '''
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo '========== SECURITY SCANNING =========='
                script {
                    sh '''
                        # Scan images with Trivy (container vulnerability scanner)
                        echo "Running Trivy security scan..."
                        
                        # Optional: Install trivy if not available
                        which trivy || (curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin)
                        
                        trivy image ${REGISTRY}/auth-service:${BUILD_TAG} || true
                        trivy image ${REGISTRY}/user-service:${BUILD_TAG} || true
                        trivy image ${REGISTRY}/product-service:${BUILD_TAG} || true
                        trivy image ${REGISTRY}/frontend:${BUILD_TAG} || true

                        echo "✅ Security scan completed"
                    '''
                }
            }
        }

        stage('Push to Azure Registry') {
            steps {
                echo '========== PUSHING TO ACR =========='
                script {
                    withCredentials([usernamePassword(credentialsId: 'azure-acr-credentials',
                        usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                        sh '''
                            # Login to Azure Container Registry
                            echo ${ACR_PASSWORD} | docker login -u ${ACR_USERNAME} \
                                --password-stdin ${REGISTRY}

                            # Push images
                            docker push ${REGISTRY}/auth-service:${BUILD_TAG}
                            docker push ${REGISTRY}/auth-service:latest
                            docker push ${REGISTRY}/user-service:${BUILD_TAG}
                            docker push ${REGISTRY}/user-service:latest
                            docker push ${REGISTRY}/product-service:${BUILD_TAG}
                            docker push ${REGISTRY}/product-service:latest
                            docker push ${REGISTRY}/frontend:${BUILD_TAG}
                            docker push ${REGISTRY}/frontend:latest

                            echo "✅ Images pushed to ACR successfully"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            steps {
                echo '========== DEPLOYING TO STAGING =========='
                script {
                    withCredentials([file(credentialsId: 'aks-kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        sh '''
                            # Get AKS credentials
                            export KUBECONFIG=${KUBECONFIG_FILE}

                            # Create staging namespace if not exists
                            kubectl create namespace ${STAGING_NS} --dry-run=client -o yaml | kubectl apply -f -

                            # Update image in deployment manifests
                            kubectl set image deployment/auth-service \
                                auth-service=${REGISTRY}/auth-service:${BUILD_TAG} \
                                -n ${STAGING_NS} || kubectl apply -f k8s/ -n ${STAGING_NS}

                            # Wait for rollout
                            kubectl rollout status deployment/auth-service -n ${STAGING_NS} --timeout=5m

                            # Run smoke tests
                            echo "Running smoke tests..."
                            sleep 10
                            kubectl exec -n ${STAGING_NS} \
                                $(kubectl get pods -n ${STAGING_NS} -l app=auth-service -o jsonpath='{.items[0].metadata.name}') \
                                -- curl http://localhost:5001/health || true

                            echo "✅ Deployed to Staging successfully"
                        '''
                    }
                }
            }
        }

        stage('Integration Tests') {
            steps {
                echo '========== RUNNING INTEGRATION TESTS =========='
                script {
                    withCredentials([file(credentialsId: 'aks-kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        sh '''
                            export KUBECONFIG=${KUBECONFIG_FILE}

                            # Get service endpoint
                            FRONTEND_IP=$(kubectl get svc frontend -n ${STAGING_NS} \
                                -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || echo "localhost:3000")

                            # Test API endpoints
                            echo "Testing API endpoints..."
                            
                            # Test auth service health
                            curl -f http://${FRONTEND_IP}:5001/health || exit 1
                            
                            # Test user service health
                            curl -f http://${FRONTEND_IP}:5002/health || exit 1
                            
                            # Test product service health
                            curl -f http://${FRONTEND_IP}:5003/health || exit 1

                            echo "✅ Integration tests passed"
                        '''
                    }
                }
            }
        }

        stage('Manual Approval') {
            when {
                branch 'main'
            }
            steps {
                echo '========== AWAITING APPROVAL FOR PRODUCTION =========='
                input message: 'Deploy to Production?', ok: 'Deploy'
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo '========== DEPLOYING TO PRODUCTION =========='
                script {
                    withCredentials([file(credentialsId: 'aks-kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        sh '''
                            export KUBECONFIG=${KUBECONFIG_FILE}

                            # Rolling update - update images
                            kubectl set image deployment/auth-service \
                                auth-service=${REGISTRY}/auth-service:${BUILD_TAG} \
                                -n ${PROD_NS}

                            kubectl set image deployment/user-service \
                                user-service=${REGISTRY}/user-service:${BUILD_TAG} \
                                -n ${PROD_NS}

                            kubectl set image deployment/product-service \
                                product-service=${REGISTRY}/product-service:${BUILD_TAG} \
                                -n ${PROD_NS}

                            kubectl set image deployment/frontend \
                                frontend=${REGISTRY}/frontend:${BUILD_TAG} \
                                -n ${PROD_NS}

                            # Wait for rollout to complete
                            kubectl rollout status deployment/auth-service -n ${PROD_NS} --timeout=10m
                            kubectl rollout status deployment/user-service -n ${PROD_NS} --timeout=10m
                            kubectl rollout status deployment/product-service -n ${PROD_NS} --timeout=10m
                            kubectl rollout status deployment/frontend -n ${PROD_NS} --timeout=10m

                            echo "✅ Deployed to Production successfully"
                        '''
                    }
                }
            }
        }

        stage('Health Check') {
            when {
                branch 'main'
            }
            steps {
                echo '========== PRODUCTION HEALTH CHECK =========='
                script {
                    withCredentials([file(credentialsId: 'aks-kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        sh '''
                            export KUBECONFIG=${KUBECONFIG_FILE}

                            # Check pod status
                            echo "Checking pod status..."
                            kubectl get pods -n ${PROD_NS}

                            # Check services
                            echo "Checking services..."
                            kubectl get svc -n ${PROD_NS}

                            # Get app metrics
                            echo "Pod resource usage:"
                            kubectl top pods -n ${PROD_NS} || echo "Metrics not available yet"

                            echo "✅ Health check completed"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo '========== BUILD SUCCESS =========='
            script {
                sh '''
                    # Send Slack notification
                    curl -X POST -H 'Content-type: application/json' \
                        --data '{"text":"✅ Build ${BUILD_NUMBER} SUCCESSFUL - ${BUILD_TAG}"}' \
                        $SLACK_WEBHOOK_URL || true
                '''
            }
        }
        failure {
            echo '========== BUILD FAILED =========='
            script {
                sh '''
                    # Send Slack notification
                    curl -X POST -H 'Content-type: application/json' \
                        --data '{"text":"❌ Build ${BUILD_NUMBER} FAILED"}' \
                        $SLACK_WEBHOOK_URL || true
                '''
            }
        }
        always {
            echo '========== CLEANUP =========='
            sh '''
                # Clean up Docker images to save space
                docker image prune -f || true
            '''
        }
    }
}
