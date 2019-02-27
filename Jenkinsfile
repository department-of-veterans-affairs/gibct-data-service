def env_vars = [
  'SECRET_KEY_BASE=0ae77385a98d4d28886d792832fbbe036152efb4a112fae2d06261850a5b6728',
  'LINK_HOST=https://www.example.com',
  'GIBCT_URL=https://www.example.com',
  'SAML_IDP_METADATA_FILE=.',
  'SAML_CALLBACK_URL=https://www.example.com/saml/auth/callback',
  'SAML_IDP_SSO_URL=https://www.example.com/idp/sso',
  'SAML_ISSUER=GIDS',
  'GOVDELIVERY_URL=stage-tms.govdelivery.com',
  'GOVDELIVERY_TOKEN=abc123'
]

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

        build job: 'deploys/gi-bill-data-service-dev', parameters: [
          booleanParam(name: 'notify_slack', value: true),
          stringParam(name: 'ref', value: commit),
        ], wait: false

        build job: 'deploys/gi-bill-data-service-staging', parameters: [
          booleanParam(name: 'notify_slack', value: true),
          stringParam(name: 'ref', value: commit),
        ], wait: false
      }
    }
  }


  post {
    always {
      sh 'make clean'
    }
  }
}
