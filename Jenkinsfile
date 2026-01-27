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
        // Poll every minute; you can switch to GitHub webhook later
        pollSCM('* * * * *')
    }

    stages {

        stage('Checkout (Fresh)') {
            steps {
                // Built-in workspace cleanup (no plugin required)
                deleteDir()

                // Pull repo & show context
                git branch: "${BRANCH}", url: "${REPO_URL}", changelog: true, poll: true
                bat 'git --version'
                bat 'git log -1 --oneline'
            }
        }

        stage('Get Commit Hash') {
            steps {
                script {
                    // Capture ONLY the hash (suppress prompt/command echo)
                    env.COMMIT_HASH = bat(
                        label: 'Get short commit hash',
                        script: '@echo off\r\nfor /f %%a in (\'git rev-parse --short HEAD\') do @echo %%a',
                        returnStdout: true
                    ).trim()
                    echo "Latest commit: ${env.COMMIT_HASH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Clear builder cache (safe)
                    bat "docker builder prune -f"

                    // Build and tag (Windows variable syntax)
                    bat "docker build --pull --no-cache --label commit_hash=%COMMIT_HASH% -t %CONTAINER_NAME%:%COMMIT_HASH% ."
                    bat "docker tag %CONTAINER_NAME%:%COMMIT_HASH% %CONTAINER_NAME%:latest"

                    // Show images
                    bat "docker images %CONTAINER_NAME%"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop previous run if exists
                    bat "docker rm -f %CONTAINER_NAME% || echo no existing container"

                    // Run new container (maps host 4000 -> container 80)
                    bat "docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %CONTAINER_NAME%:%COMMIT_HASH%"

                    // Show status
                    bat "docker ps --filter name=%CONTAINER_NAME%"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    // Give the container a few seconds
                    sleep 5

                    // Curl check (expects 200 if Nginx serves index.html)
                    bat "curl -s -o NUL -w \"HTTP %{http_code}\\n\" http://localhost:%PORT%"

                    // Optional: print image id currently running
                    def imageId = bat(
                        script: "docker inspect %CONTAINER_NAME% --format=\"{{.Image}}\"",
                        returnStdout: true
                    ).trim()
                    echo "Container %CONTAINER_NAME% is using image ID: ${imageId}"
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment complete! Visit: http://localhost:${PORT}"
        }
        failure {
            echo "❌ Deployment failed. Check above logs; see the checklist below if needed."
            script {
                bat "docker logs --tail 200 %CONTAINER_NAME% || echo no container logs"
            }
        }
    }
}
