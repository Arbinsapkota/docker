pipeline {
  agent any
  options { timestamps() }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate Files') {
      steps {
        bat '''
          if not exist index.html (echo index.html NOT FOUND! & exit /b 1)
          if not exist style.css  (echo style.css NOT FOUND!  & exit /b 1)
          echo OK: Found index.html and style.css
        '''
      }
    }

    stage('Serve Website on Port 3000') {
      steps {

        // Free port 3000 if something is already using it
        bat '''
          powershell -NoProfile -Command ^
            "$c = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue; ^
             if ($c) { try { Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue } catch {} }"
        '''

        // Detect whether 'py' or 'python' is available
        bat '''
          set "PYCMD="
          where py >nul 2>nul && set "PYCMD=py -3"
          if not defined PYCMD where python >nul 2>nul && set "PYCMD=python"
          if not defined PYCMD (
            echo ERROR: Python not found in PATH!
            exit /b 1
          )

          for %%A in ("%WORKSPACE%") do set "WDIR=%%~fA"
          echo Using Python command: %PYCMD%
          echo Starting server from %WDIR% ...

          start "" /B cmd /c "cd /d %WDIR% && %PYCMD% -m http.server 3000 > %TEMP%\\site-3000.log 2>&1"

          echo ==================================================
          echo  WEBSITE LIVE: http://localhost:3000/
          echo  LOG FILE: %TEMP%\\site-3000.log
          echo ==================================================
        '''
      }
    }
  }

  post {
    success {
      echo 'Success! Open http://localhost:3000/'
    }
    failure {
      echo 'Build failed. Check Console Output for errors.'
    }
  }
}





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
