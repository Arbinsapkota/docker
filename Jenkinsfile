pipeline {
    agent any

    environment {
        REPO_URL = "https://github.com/Arbinsapkota/docker.git"
        BRANCH = "main"
        CONTAINER_NAME = "site2"
        PORT = "4000"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Get Commit Hash') {
            steps {
                script {
                    COMMIT_HASH = bat(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "✅ Latest commit hash: ${COMMIT_HASH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🚧 Building Docker image..."
                    bat "docker build --no-cache -t ${CONTAINER_NAME}:${COMMIT_HASH} ."
                    bat "docker tag ${CONTAINER_NAME}:${COMMIT_HASH} ${CONTAINER_NAME}:latest"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    echo "🚀 Deploying container..."
                    bat """
                    docker rm -f ${CONTAINER_NAME} || echo Container not found
                    """
                    bat "docker run -d -p ${PORT}:80 --name ${CONTAINER_NAME} ${CONTAINER_NAME}:${COMMIT_HASH}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sleep(5) // Wait a few seconds for container to initialize
                    IMAGE_ID = bat(script: "docker inspect ${CONTAINER_NAME} --format='{{.Image}}'", returnStdout: true).trim()
                    DEPLOYED_HASH = bat(script: "docker images --format=\"{{.ID}} {{.Repository}}:{{.Tag}}\" | findstr ${IMAGE_ID}", returnStdout: true).trim()
                    echo "✅ Container ${CONTAINER_NAME} deployed with image: ${DEPLOYED_HASH}"
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Static site deployed successfully! Check at http://localhost:${PORT}"
        }
        failure {
            echo "❌ Deployment failed. Check the logs for errors."
        }
    }
}
