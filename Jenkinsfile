def env_vars = [
  'SECRET_KEY_BASE=0ae77385a98d4d28886d792832fbbe036152efb4a112fae2d06261850a5b6728',
  'LINK_HOST=https://www.example.com',
  'GIBCT_URL=https://www.example.com',
  'SAML_IDP_METADATA_FILE=.'
  'SAML_CALLBACK_URL=https://www.example.com/saml/auth/callback',
  'SAML_IDP_SSO_URL=https://www.example.com/idp/sso',
  'SAML_ISSUER=GIDS'
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
  }

  post {
    always {
      sh 'make clean'
    }
  }
}
