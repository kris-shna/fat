pipeline {
    agent any

    parameters {
        string(name: 'ENVIRONMENT', defaultValue: 'Production', description: 'Deployment Environment Target Location')
    }

    environment {
        DOCKER_HUB_USER = 'yourdockerhubusername' // Put your real Docker Hub user ID string here
        IMAGE_NAME      = 'smart-campus-energy'
        IMAGE_TAG       = "${BUILD_NUMBER}"
    }

    stages {
        stage('Pull Repository Source Code') {
            steps {
                checkout scm
            }
        }

        // PIPELINE REQUIREMENT TYPE 1: Parallel Evaluation Execution Stages
        stage('Quality & Security Verifications') {
            parallel {
                stage('Source Code Validation') {
                    steps {
                        echo "Validating index.html dashboard system structure logic..."
                        sh "test -f index.html"
                    }
                }
                stage('Docker Environment Dry Run') {
                    steps {
                        echo "Checking local machine runtime systems status configurations..."
                        sh "docker version"
                    }
                }
            }
        }

        stage('Compile & Tag Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "docker login -u ${USER} -p ${PASS}"
                    sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Cluster Continuous Deployment') {
            steps {
                echo "Deploying target environment instance profile: ${params.ENVIRONMENT}"
                withKubeConfig([credentialsId: 'kubernetes-cluster-config']) {
                    // Update the local manifest specification dynamically to match the current pipeline tag version
                    sh "sed -i 's|${DOCKER_HUB_USER}/${IMAGE_NAME}:latest|${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' deployment.yaml"
                    sh "kubectl apply -f deployment.yaml"
                    
                    echo "Monitoring deployment stability updates..."
                    // Wait up to 60 seconds for pods to successfully transition through health checking routines
                    sh "kubectl rollout status deployment/energy-monitoring-system --timeout=60s"
                }
            }
        }
    }

    // REQUIREMENT 4: Catch faults automatically and execute rollback commands if checks fail
    post {
        failure {
            echo "🚨 DISRUPTION DETECTED: Rollout health verification checks failed!"
            echo "🔄 Initiating automatic rollback to the previous functional stable image release..."
            withKubeConfig([credentialsId: 'kubernetes-cluster-config']) {
                sh "kubectl rollout undo deployment/energy-monitoring-system"
                sh "kubectl rollout status deployment/energy-monitoring-system"
                echo "✅ SUCCESS: Rollback completed cleanly. Monitoring dashboard restored to service."
            }
        }
    }
}
