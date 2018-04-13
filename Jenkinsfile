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

    stage('Install bundle') {
      steps {
        sh 'yum install postgresql-devel'
        sh 'bash --login -c "bundle install -j 4 --without development"'
      }
    }

    stage('Prepare database') {
      steps {
        withEnv(env_vars) {
          sh 'bash --login -c "bundle exec rake db:drop db:create db:schema:load"'
        }
      }
    }

    stage('Run tests') {
      steps {
        withEnv(env_vars) {
          sh 'bash --login -c "bundle exec rake ci"'
        }
      }
    }
  }
}
