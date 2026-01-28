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

  // Poll every minute. Remove this if you later enable a working GitHub webhook.
  triggers { pollSCM('* * * * *') }

  stages {

    stage('Checkout & Info') {
      steps {
        // Jenkins already checks out when "Pipeline from SCM" is used,
        // these just help with visibility and debugging.
        bat 'git --version'
        bat 'git log -1 --oneline'
      }
    }

    stage('Get Commit Hash') {
      steps {
        script {
          env.COMMIT_HASH = bat(
            label: 'Get short commit hash',
            script: '@echo off\r\nfor /f %%a in (\'git rev-parse --short HEAD\') do @echo %%a',
            returnStdout: true
          ).trim()
          echo "Commit: ${env.COMMIT_HASH}"
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        // Build cleanly and tag with commit + latest
        bat 'docker builder prune -f'
        bat 'docker build --pull --no-cache --label commit_hash=%COMMIT_HASH% -t %CONTAINER_NAME%:%COMMIT_HASH% .'
        bat 'docker tag %CONTAINER_NAME%:%COMMIT_HASH% %CONTAINER_NAME%:latest'
      }
    }

    stage('Deploy') {
      steps {
        // Replace running container with the new image
        bat 'docker rm -f %CONTAINER_NAME% || echo no existing container'
        bat 'docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %CONTAINER_NAME%:%COMMIT_HASH%'
      }
    }

    stage('Verify') {
      steps {
        // Use PowerShell for a robust HTTP 200 check on Windows
        bat '''
powershell -NoProfile -Command ^
  "$r = Invoke-WebRequest -Uri http://localhost:%PORT% -UseBasicParsing; ^
   Write-Host ('HTTP ' + $r.StatusCode); ^
   if ($r.StatusCode -ge 400) { exit 1 }"
'''
      }
    }
  }

  post {
    success {
      echo "✅ Deployed: http://localhost:${PORT}"
    }
    failure {
      echo "❌ Deployment failed. Container logs (tail):"
      bat 'docker logs --tail 200 %CONTAINER_NAME% || echo no container logs'
    }
  }
}