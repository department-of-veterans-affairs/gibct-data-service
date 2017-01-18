pipeline {
  agent {
    label 'rails-testing'
  }
  stages {
    stage('Checkout Code') {
      steps {
        checkout scm

        sh 'rm -rf gi-bill-comparison-tool'
        sh 'git clone https://github.com/department-of-veterans-affairs/gi-bill-comparison-tool'
      }
    }

    stage('Install bundle') {
      steps {
        sh 'bundle install -j 4 --without development'

        dir('gi-bill-comparison-tool') {
          sh 'bundle install -j 4 --without development'
        }
      }
    }

    stage('Audit') {
      steps {
        sh 'bundle exec rake security'
      }
    }

    stage('Prepare') {
      steps {
        sh 'bundle exec rake db:drop'

        dir('gi-bill-comparison-tool') {
          sh 'RAILS_ENV=test bundle exec rake db:drop'
        }
      }
    }

    stage('Ensure database') {
      steps {
        sh 'bundle exec rake db:create db:migrate'

        dir('gi-bill-comparison-tool') {
          sh 'RAILS_ENV=test bundle exec rake db:create db:migrate'
        }
      }
    }

    stage('Run tests') {
      steps {
        sh 'bundle exec rspec'
      }
    }
  }
}
