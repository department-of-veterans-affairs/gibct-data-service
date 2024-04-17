#!/bin/bash -e

# TODO: Remove me after Dockerfile is replaced by Dockerfile-k8s, which points 
# to /bin/docker-entrypoint

# note this logic is duplciated in the Dockerfile for prod builds,
# if you make major alteration here, please check that usage as well
bundle check || bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin"

exec "$@"
