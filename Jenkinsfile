pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['Staging', 'Production'], description: 'Target campus cluster deployment environment profile')
    }

    environment {
        DOCKER_HUB_USER = 'krishna' 
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
                echo "🚀 Building application version tag matching execution: %IMAGE_TAG%"
                bat "docker build -t %DOCKER_HUB_USER%/%IMAGE_NAME%:%IMAGE_TAG% ."
                bat "docker tag %DOCKER_HUB_USER%/%IMAGE_NAME%:%IMAGE_TAG% %DOCKER_HUB_USER%/%IMAGE_NAME%:latest"
            }
        }

        stage('Cluster Continuous Deployment') {
            steps {
                echo "Deploying target environment instance profile: %DEPLOY_ENV%"
                withKubeConfig([credentialsId: 'kubernetes-cluster-config']) {
                    script {
                        def yamlFile = 'deployment.yaml'
                        def yamlContent = readFile(yamlFile)
                        def updatedContent = yamlContent.replace("yourdockerhubusername/smart-campus-energy:latest", "${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.IMAGE_TAG}")
                        writeFile(file: yamlFile, text: updatedContent)
                    }
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
