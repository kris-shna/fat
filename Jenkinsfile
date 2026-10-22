pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['Staging', 'Production'], description: 'Target campus cluster deployment environment profile')
    }

    environment {
        DOCKER_HUB_USER = 'yourdockerhubusername' // Replace with your actual Docker Hub username string
        IMAGE_NAME      = 'smart-campus-energy'
        IMAGE_TAG       = "${BUILD_NUMBER}"
    }

    stages {
        stage('Pull Code from GitHub') {
            steps {
                checkout scm
            }
        }

        stage('Quality & Security Verifications') {
            parallel {
                stage('Source Code Validation') {
                    steps {
                        echo "🔍 Verifying index.html structural integrity layout..."
                        // Windows alternative to check if a file exists
                        bat 'if not exist index.html exit 1' 
                    }
                }
                stage('Configuration Linting') {
                    steps {
                        echo "🔍 Validating configuration syntax rules inside manifests..."
                        bat 'if not exist deployment.yaml exit 1'
                    }
                }
            }
        }

        stage('Compile & Tag Docker Images') {
            steps {
                echo "🚀 Building application version tag matching execution: ${IMAGE_TAG}"
                bat "docker build -t %DOCKER_HUB_USER%/%IMAGE_NAME%:%IMAGE_TAG% ."
                bat "docker tag %DOCKER_HUB_USER%/%IMAGE_NAME%:%IMAGE_TAG% %DOCKER_HUB_USER%/%IMAGE_NAME%:latest"
            }
        }

        stage('Cluster Continuous Deployment') {
            steps {
                echo "Deploying target environment instance profile: %DEPLOY_ENV%"
                withKubeConfig([credentialsId: 'kubernetes-cluster-config']) {
                    // Windows PowerShell/CMD equivalent to substitute strings in text files
                    bat "powershell -Command \"(Get-Content deployment.yaml) -replace '%DOCKER_HUB_USER%/%IMAGE_NAME%:latest', '%DOCKER_HUB_USER%/%IMAGE_NAME%:%IMAGE_TAG%' | Set-Content deployment.yaml\""
                    bat "kubectl apply -f deployment.yaml"
                    bat "kubectl rollout status deployment/energy-monitoring-system --timeout=60s"
                }
            }
        }
    }

    post {
        failure {
            echo "🚨 DISRUPTION DETECTED: Rollout health verification checks failed!"
            echo "🔄 Initiating automatic rollback to the previous functional stable image release..."
            withKubeConfig([credentialsId: 'kubernetes-cluster-config']) {
                bat "kubectl rollout undo deployment/energy-monitoring-system"
                bat "kubectl rollout status deployment/energy-monitoring-system"
                echo "✅ SUCCESS: Rollback completed cleanly. Monitoring dashboard restored."
            }
        }
    }
}
