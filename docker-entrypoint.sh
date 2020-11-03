#!/bin/bash -e

# note this logic is duplciated in the Dockerfile for prod builds,
# if you make major alteration here, please check that usage as well


#source $NVM_DIR/nvm.sh
#nvm install $NODEJS_VERSION


bundle check || bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin"
yarn install --force --non-interactive

#yarn

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
