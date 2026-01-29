pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timestamps()
    timeout(time: 20, unit: 'MINUTES')
  }

  environment {
    CONTAINER_NAME = 'site2'
    PORT           = '4000'
  }

  // Poll every minute (remove after you switch to a GitHub webhook)
  triggers { pollSCM('* * * * *') }

  stages {

    // Optional but recommended: resilient checkout
    stage('Checkout') {
      steps {
        script {
          retry(3) {
            sleep time: 2, unit: 'SECONDS' // small backoff smooths race with polling
            checkout scm
          }
        }
      }
    }

    stage('Checkout & Info') {
      steps {
        // Jenkins already does an SCM checkout when "Pipeline from SCM" is used,
        // but this stage gives useful context in logs.
        bat 'git --version & docker --version'
        bat 'git log -1 --oneline'
      }
    }

    stage('Get Commit Hash') {
      steps {
        script {
          env.COMMIT_HASH = bat(
            label: 'Get short commit hash',
            script: '@echo off\r\nfor /f %a in (\'git rev-parse --short HEAD\') do @echo %a',
            returnStdout: true
          ).trim()
          echo "Commit: ${env.COMMIT_HASH}"
        }
      }
    }

    stage('Build Image') {
      steps {
        // Use cache for faster builds (no --no-cache)
        bat 'docker build -t %CONTAINER_NAME%:%COMMIT_HASH% .'
        bat 'docker tag %CONTAINER_NAME%:%COMMIT_HASH% %CONTAINER_NAME%:latest'
      }
    }

    stage('Deploy') {
      steps {
        bat 'docker rm -f %CONTAINER_NAME% 2>NUL || echo no existing container'
        bat 'docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %CONTAINER_NAME%:%COMMIT_HASH%'
      }
    }

    stage('Verify') {
      steps {
        // Windows curl: use %% to escape %{http_code} for CMD
        bat 'curl --fail --silent --show-error --location -o NUL -w "HTTP %%{http_code}\\n" http://localhost:%PORT%'
      }
    }
  }

  post {
    success {
      echo "✅ Deployed: http://localhost:${PORT}"
    }
    failure {
      echo "❌ Deployment failed. Container logs:"
      // Ensure a node/workspace exists even if checkout failed
      node {
        bat 'docker ps -a'
        bat 'docker logs --tail 200 %CONTAINER_NAME% || echo no container logs'
      }
    }
  }
}