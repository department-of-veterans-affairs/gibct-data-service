def env_vars = [
  'SECRET_KEY_BASE=0ae77385a98d4d28886d792832fbbe036152efb4a112fae2d06261850a5b6728'
  'LINK_HOST=https://www.example.com'
]

pipeline {
  agent {
    label 'rails-testing'
  }
  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Install bundle') {
      steps {
        sh 'bash --login -c "bundle install -j 4 --without development"'
      }
    }

    stage('Audit') {
      steps {
        withEnv(env_vars) {
          sh 'bash --login -c "bundle exec rake ci"'
        }
      }
    }

    stage('Prepare') {
      steps {
        withEnv(env_vars) {
          sh 'bash --login -c "bundle exec rake db:drop"'
        }
      }
    }

    stage('Ensure database exists') {
      steps {
        withEnv(env_vars) {
          sh 'bash --login -c "bundle exec rake db:create db:migrate"'
        }
      }
    }

    stage('Run tests') {
      steps {
        withEnv(env_vars) {
          sh 'bash --login -c "bundle exec rspec"'
        }
      }
    }
  }
}
