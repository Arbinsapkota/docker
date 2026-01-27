pipeline {
    agent any

    environment {
        REPO_URL = "https://github.com/Arbinsapkota/docker.git"
        BRANCH = "main"
        CONTAINER_NAME = "site2"
        PORT = "4000"
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()   // prevent using old workspace
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Get Commit Hash') {
            steps {
                script {
                    COMMIT_HASH = bat(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "Latest commit: ${COMMIT_HASH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker builder prune -f"   // clear cache
                    bat "docker build --no-cache -t ${CONTAINER_NAME}:${COMMIT_HASH} ."
                    bat "docker tag ${CONTAINER_NAME}:${COMMIT_HASH} ${CONTAINER_NAME}:latest"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    bat "docker rm -f ${CONTAINER_NAME} || echo no container"
                    bat "docker run -d -p ${PORT}:80 --name ${CONTAINER_NAME} ${CONTAINER_NAME}:${COMMIT_HASH}"
                }
            }
        }
    }

    post {
        success {
            echo "Deployment complete!"
        }
    }
}