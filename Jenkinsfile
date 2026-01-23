
pipeline {
  agent any

  options { timestamps() }

  environment {
    // Where Apache serves files (XAMPP on Windows)
    DEPLOY_DIR = 'C:\\xampp\\htdocs'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Clean target folder') {
      steps {
        // Windows-safe cleanup: delete contents but not the folder itself
        bat '''
          if exist "%DEPLOY_DIR%" (
            del /Q "%DEPLOY_DIR%\\*.*" 2>nul
            for /d %%d in ("%DEPLOY_DIR%\\*") do @rd /s /q "%%d"
          ) else (
            mkdir "%DEPLOY_DIR%"
          )
        '''
      }
    }

    stage('Deploy HTML/CSS/JS') {
      steps {
        // Copy everything except .git and Jenkinsfile itself
        bat '''
          xcopy * "%DEPLOY_DIR%" /E /H /C /Y /I
          if exist ".git" rd /s /q ".git"
        '''
      }
    }
  }

  post {
    success { echo '✅ Deployed to XAMPP. Open http://localhost to see the update.' }
    failure { echo '❌ Deployment failed. Check Console Output.' }
  }
}


// pipeline {
//     agent any

//     stages {
//         stage('Checkout') {
//             steps {
//                 checkout scm
//             }
//         }

//         stage('Deploy HTML Files') {
//             steps {
//                 // Replace with your server path
//                 sh '''
//                     sudo rm -rf /var/www/html/*
//                     sudo cp -r * /var/www/html/
//                 '''
//             }
//         }
//     }

//     post {
//         success {
//             echo "Website updated successfully!"
//         }
//     }
// }


// Example Jenkinsfile for Linux/MacOS systems using shell commands

// pipeline {
//   agent any

//   stages {

//     stage('Checkout Code') {
//       steps {
//         git branch: 'main', url: 'https://github.com/<your-username>/<your-repo>.git'
//       }
//     }

//     stage('Validate Files') {
//       steps {
//         sh '''
//           test -f index.html || (echo "index.html NOT FOUND!" && exit 1)
//           test -f style.css  || (echo "style.css NOT FOUND!" && exit 1)
//         '''
//       }
//     }

//     stage('Serve Website on Port 3000') {
//       steps {
//         sh '''
//           pkill -f "python3 -m http.server 3000" || true
//           nohup python3 -m http.server 3000 >/tmp/website.log 2>&1 &
//           echo "Your site is LIVE at http://localhost:3000/"
//         '''
//       }
//     }
//   }

//   post {
//     success {
//       echo "DONE! Open http://localhost:3000/"
//     }
//   }
// }
