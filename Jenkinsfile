pipeline {
    agent any

    options {
        disableConcurrentBuilds()     // avoid overlapping runs
        timestamps()                  // timestamps in logs
        ansiColor('xterm')            // nicer colors in console
        timeout(time: 20, unit: 'MINUTES') // guardrail for stuck builds
    }

    environment {
        REPO_URL = "https://github.com/Arbinsapkota/docker.git"
        BRANCH = "main"
        CONTAINER_NAME = "site2"
        PORT = "4000"
        // COMMIT_HASH will be set at runtime via env.COMMIT_HASH
    }

    triggers {
        // Poll every minute (you can switch to GitHub webhook later)
        pollSCM('* * * * *')
    }

    stages {

        stage('Checkout (Fresh)') {
            steps {
                cleanWs()   // ensure no stale .git or files
                git branch: "${BRANCH}", url: "${REPO_URL}", changelog: true, poll: true
                bat 'git --version'
                bat 'git log -1 --oneline'
            }
        }

        stage('Get Commit Hash') {
            steps {
                script {
                    // ✅ Use env.COMMIT_HASH so it is available in later stages
                    env.COMMIT_HASH = bat(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "Latest commit: ${env.COMMIT_HASH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${CONTAINER_NAME}:${env.COMMIT_HASH}"
                    // Optional but helpful: ensure no stray cache / buildx builders
                    bat "docker builder prune -f"
                    // ✅ --pull ensures latest base images
                    bat "docker build --pull --no-cache -t ${CONTAINER_NAME}:${env.COMMIT_HASH} ."
                    bat "docker tag ${CONTAINER_NAME}:${env.COMMIT_HASH} ${CONTAINER_NAME}:latest"
                    bat "docker images ${CONTAINER_NAME}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    echo "Stopping old container (if exists)"
                    bat "docker rm -f ${CONTAINER_NAME} || echo no existing container"

                    echo "Starting new container on port ${PORT}"
                    bat """
                    docker run -d -p ${PORT}:80 --name ${CONTAINER_NAME} ${CONTAINER_NAME}:${env.COMMIT_HASH}
                    """

                    // Show container status
                    bat "docker ps --filter name=${CONTAINER_NAME}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    // Small wait for app to boot
                    sleep 5

                    echo "Verifying with curl http://localhost:${PORT}"
                    // On Windows, curl is available. You can also use PowerShell Invoke-WebRequest.
                    bat """
                    curl -s -o NUL -w "HTTP %{http_code}\\n" http://localhost:${PORT}
                    """

                    // (optional) Map image ID -> tag for audit
                    def imageId = bat(script: "docker inspect ${CONTAINER_NAME} --format='{{.Image}}'", returnStdout: true).trim()
                    echo "Container ${CONTAINER_NAME} running image ID: ${imageId}"
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment complete! Visit: http://localhost:${PORT}"
        }
        failure {
            echo "❌ Deployment failed. Check the stage logs above."
            // Optional: dump last 100 lines of container logs for debugging
            script {
                bat "docker logs --tail 100 ${CONTAINER_NAME} || echo no logs"
            }
        }
        cleanup {
            echo "Build finished at: ${new Date()}"
        }
    }
}
