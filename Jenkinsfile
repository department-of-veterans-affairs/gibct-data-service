def env_vars = [
  'SECRET_KEY_BASE=0ae77385a98d4d28886d792832fbbe036152efb4a112fae2d06261850a5b6728',
  'LINK_HOST=https://www.example.com',
  'GIBCT_URL=https://www.example.com'
]

pipeline {
  agent {
    label 'vetsgov-general-purpose'
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Run tests') {
      steps {
        sh 'make ci'
      }
    }
r }
}
