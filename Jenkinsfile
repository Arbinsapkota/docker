pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
        timeout(time: 20, unit: 'MINUTES')
    }

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

        stage('Checkout (Fresh)') {
            steps {
                deleteDir()
                git branch: "${BRANCH}", url: "${REPO_URL}", changelog: true, poll: true
                bat 'git --version'
                bat 'git log -1 --oneline'
            }
        }

        stage('Get Commit Hash') {
            steps {
                script {
                    env.COMMIT_HASH = bat(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    echo "Latest commit: ${env.COMMIT_HASH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker builder prune -f"
                    // ⭐ Correct Windows syntax
                    bat "docker build --pull --no-cache -t %CONTAINER_NAME%:%COMMIT_HASH% ."
                    bat "docker tag %CONTAINER_NAME%:%COMMIT_HASH% %CONTAINER_NAME%:latest"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    bat "docker rm -f %CONTAINER_NAME% || echo no existing container"
                    bat "docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %CONTAINER_NAME%:%COMMIT_HASH%"
                    bat "docker ps --filter name=%CONTAINER_NAME%"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sleep 5
                    bat "curl -s -o NUL -w \"HTTP %{http_code}\\n\" http://localhost:%PORT%"
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment complete! Visit: http://localhost:${PORT}"
        }
        failure {
            echo "❌ Deployment failed."
        }
    }
}
