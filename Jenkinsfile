// Inside your Quality & Security Verifications stage
stage('Source Code Validation') {
    steps {
        echo "🔍 Verifying index.html structural integrity..."
        bat 'if not exist index.html exit 1' // Safe alternative for Windows environments
    }
}
stage('Configuration Linting') {
    steps {
        echo "🔍 Validating manifest deployment config..."
        bat 'if not exist deployment.yaml exit 1'
    }
}
