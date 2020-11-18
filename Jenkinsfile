pipeline {
  agent {
    label 'vetsgov-general-purpose'
  }

  environment {
    DOCKER_IMAGE = env.BUILD_TAG.replaceAll(/[%\/]/, '')
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

    stage('Deploy dev and staging') {
      when { branch 'master' }

      steps {
        // hack to get the commit hash, some plugin is swallowing git variables and I can't figure out which one
        script {
          commit = sh(returnStdout: true, script: "git rev-parse HEAD").trim()
        }

        build job: 'builds/gi-bill-data-service', parameters: [
          booleanParam(name: 'notify_slack', value: false),
          stringParam(name: 'ref', value: commit),
          booleanParam(name: 'release', value: false),
        ], wait: true

        build job: 'deploys/gi-bill-data-service-vagov-dev', parameters: [
          booleanParam(name: 'notify_slack', value: true),
          booleanParam(name: 'migration_status', value: true),
          stringParam(name: 'ref', value: commit),
        ], wait: false

        build job: 'deploys/gi-bill-data-service-vagov-staging', parameters: [
          booleanParam(name: 'notify_slack', value: true),
          booleanParam(name: 'migration_status', value: true),
          stringParam(name: 'ref', value: commit),
        ], wait: false
      }
    }
  }


  post {
    always {
      sh 'make clean'
      deleteDir()
    }
  }
}
