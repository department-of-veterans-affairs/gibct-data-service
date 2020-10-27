#!/bin/bash -e

# note this logic is duplciated in the Dockerfile for prod builds,
# if you make major alteration here, please check that usage as well
bundle check || bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin"

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh
#ENV NVM_DIR=/root/.nvm
source nvm.sh
nvm install ${NODEJS_VERSION}

#apt-get update
#apt-get install nodejs
#apt-get install npm
#npm install yarn -g

# Configure gibct application
#RUN mkdir -p /src/gibct && chown gibct:gibct /src/gibct
#VOLUME /src/gibct
#WORKDIR /src/gibct
#
#ADD . /src/gibct
#RUN ["/bin/bash", "--login", "-c", "bundle install -j4"]
#RUN yarn install --force --non-interactive
#yarn install --force --non-interactive

exec "$@"
