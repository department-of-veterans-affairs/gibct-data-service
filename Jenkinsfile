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
        sh 'bash --login -c "bundle exec rake ci"'
      }
    }

    stage('Prepare') {
      steps {
        sh 'bash --login -c "bundle exec rake db:drop"'
      }
    }

    stage('Ensure database exists') {
      steps {
        sh 'bash --login -c "bundle exec rake db:create db:migrate"'
      }
    }

    stage('Run tests') {
      steps {
        sh 'bash --login -c "bundle exec rspec"'
      }
    }
  }
}
