pipeline {
  agent any

  /**********************************************************************
   * CONFIG QUICK GUIDE
   * --------------------------------------------------------------------
   * CONTAINER_NAME  -> Name of the running container
   * PORT            -> Host port mapped to container port 80 (nginx)
   * IMAGE_BASENAME  -> Docker image base name
   * VERIFY_URL      -> URL used in Verify stage (curl check)
   **********************************************************************/

  options {
    disableConcurrentBuilds()   // Prevent parallel deployments
    timestamps()                // Add timestamps to logs
    timeout(time: 20, unit: 'MINUTES')
  }

  environment {
    // 🔁 Docker container name
    CONTAINER_NAME = 'staticsite1'

    // 🔁 Host port (browse http://localhost:4040)
    PORT = '4040'

    // 🏷️ Docker image name
    IMAGE_BASENAME = 'staticsite1'

    // 🌐 Health-check URL
    VERIFY_URL = "http://localhost:4040"
  }

  // ⏱️ SCM polling (can be replaced with GitHub webhook later)
  triggers {
    pollSCM('* * * * *')
  }

  stages {

    stage('Checkout & Info') {
      steps {
        // 🧰 Print tool versions for debugging
        bat 'git --version & docker --version'

        // 📜 Show last commit details
        bat 'git log -1 --oneline'
      }
    }

    stage('Get Commit Hash') {
      steps {
        script {
          // 🏷️ Get short Git commit hash
          env.COMMIT_HASH = bat(
            label: 'Get short commit hash',
            script: '@echo off\r\nfor /f %%a in (\'git rev-parse --short HEAD\') do @echo %%a',
            returnStdout: true
          ).trim()

          echo "Commit Hash: ${env.COMMIT_HASH}"
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        // 🏗️ Build Docker image using commit hash tag
        bat 'docker build -t %IMAGE_BASENAME%:%COMMIT_HASH% .'

        // 🏷️ Tag same image as latest (optional but useful)
        bat 'docker tag %IMAGE_BASENAME%:%COMMIT_HASH% %IMAGE_BASENAME%:latest'
      }
    }

    stage('Deploy (Docker Compose)') {
      steps {
        /**
         * Now:
         *   - Docker Compose manages container lifecycle
         *   - Cleaner, scalable, production-style deployment
         */

        bat '''
        echo Stopping old containers (if any)...
        docker compose down || echo no existing containers

        echo Starting container using Docker Compose...
        docker compose up -d
        '''
      }
    }

    stage('Verify') {
      steps {
        // 🔍 Verify deployment using HTTP status check
        bat 'curl --fail --silent --show-error --location -o NUL -w "HTTP %%{http_code}\\n" %VERIFY_URL%'
      }
    }
  }

  post {
    success {
      // ✅ Successful deployment message
      echo "✅ Application deployed successfully at ${env.VERIFY_URL}"
    }

    failure {
      // ❌ Print logs if deployment fails
      echo "❌ Deployment failed. Showing container logs:"
      bat 'docker logs --tail 200 %CONTAINER_NAME% || echo no container logs'
    }
  }
}
