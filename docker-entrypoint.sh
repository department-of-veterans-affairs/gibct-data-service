#!/bin/bash -e

# note this logic is duplciated in the Dockerfile for prod builds,
# if you make major alteration here, please check that usage as well
bundle check || bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin"
touch ~/.bashrc
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
export NVM_DIR="/srv/gi-bill-data-service/.nvm"
. "$NVM_DIR/nvm.sh" && nvm install ${NODEJS_VERSION}
export PATH="${NVM_DIR}/versions/node/v${NODEJS_VERSION}/bin:${PATH}"
npm install -g yarn@$YARN_VERSION
yarn install --force --non-interactive

exec "$@"
