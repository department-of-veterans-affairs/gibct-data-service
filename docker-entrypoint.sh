#!/bin/bash -e

# note this logic is duplciated in the Dockerfile for prod builds,
# if you make major alteration here, please check that usage as well
bundle check || bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin"

bundle exec rails webpacker:install
bundle exec rails webpacker:install:react
bundle exec rails generate react:install

exec "$@"
