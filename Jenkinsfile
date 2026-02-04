pipeline {
  agent any

  /**********************************************************************
   * CONFIG QUICK GUIDE (edit here as needed)
   * --------------------------------------------------------------------
   * 1) CONTAINER_NAME  -> The container name Docker will run (e.g., "site2")
   * 2) PORT            -> Host port that maps to container port 80
   *                       Example: 4000 means you browse http://localhost:4000
   * 3) VERIFY_URL      -> The URL curl will check in the Verify stage
   *                       If you change PORT, update VERIFY_URL too.
   * 4) IMAGE_BASENAME  -> The base image name you want to build/tag locally
   *                       (kept same as CONTAINER_NAME by default)
   *
   * To change container name: set CONTAINER_NAME = 'myapp'
   * To change host port:      set PORT = '8080' and update VERIFY_URL accordingly
   **********************************************************************/
  options {
    disableConcurrentBuilds()
    timestamps()
    timeout(time: 20, unit: 'MINUTES')
  }

  environment {
    // 🔁 CHANGE THIS to rename the running Docker container
    CONTAINER_NAME = 'staticsitehtml'

    // 🔁 CHANGE THIS to expose a different host port (container still listens on 80)
    // e.g., '8080' -> curl http://localhost:8080
    PORT = '4040'

    // 🏷️ Image base name (local). Usually same as container name; adjust if desired.
    // If you change this, Jenkins will build/tag IMAGE_BASENAME:<commit/ latest>
    IMAGE_BASENAME = "${CONTAINER_NAME}"

    // 🌐 Verify URL (used by curl). If you change PORT or host, update this.
    VERIFY_URL = "http://localhost:${PORT}"
  }

  // ⏱️ Poll every minute (replace with webhook when ready)
  triggers { pollSCM('* * * * *') }

  stages {

    stage('Checkout & Info') {
      steps {
        // 🧰 Tool versions for quick diagnostics
        bat 'git --version & docker --version'
        // 📜 Show last commit that this build uses
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


    stage('Build Image') {
      steps {
        // 🏗️ Build local image: IMAGE_BASENAME:COMMIT and tag 'latest'
        // If you changed IMAGE_BASENAME above, it applies here automatically.
        bat 'docker build -t %IMAGE_BASENAME%:%COMMIT_HASH% .'
        bat 'docker tag %IMAGE_BASENAME%:%COMMIT_HASH% %IMAGE_BASENAME%:latest'
      }
    }

    stage('Deploy') {
      steps {
        // 🧹 Stop & remove old container if it exists (ignore errors)
        bat 'docker rm -f %CONTAINER_NAME% 2>NUL || echo no existing container'

        // ▶️ Run new container
        // If you changed PORT or CONTAINER_NAME above, no need to edit here.
        // Host:%PORT% -> Container:80 (Nginx listens on 80 in the image)
        bat 'docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %IMAGE_BASENAME%:%COMMIT_HASH%'
      }
    }

    stage('Verify') {
      steps {
        // 🔍 Health check via HTTP status code on VERIFY_URL
        // If you changed PORT or domain, update VERIFY_URL in environment.
        bat 'curl --fail --silent --show-error --location -o NUL -w "HTTP %%{http_code}\\n" %VERIFY_URL%'
      }
    }
  }

  post {
    success {
      echo "✅ Deployed: ${env.VERIFY_URL}"
    }
    failure {
      echo "❌ Deployment failed. Container logs (if present):"
      // Safe to run even if container wasn't created
      bat 'docker logs --tail 200 %CONTAINER_NAME% || echo no container logs'
    }
  }
}