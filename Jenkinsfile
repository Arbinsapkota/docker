pipeline {
    agent any

    environment {
        IMAGE_NAME = "static"
        CONTAINER_NAME = "static"
        PORT = "5000"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Arbinsapkota/docker.git'
            }
        }

        stage('Build Image') {
            steps {
                bat "docker build -t %IMAGE_NAME% ."
            }
        }

        stage('Deploy Container') {
            steps {
                bat """
                docker rm -f %CONTAINER_NAME% || echo Container not found
                docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %IMAGE_NAME%
                """
            }
        }
    }

    post {
        success {
            echo "✅ Static site deployed successfully!"
        }
        failure {
            echo "❌ Deployment failed. Check logs."
        }
    }
}
