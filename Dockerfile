###
# base
#
# shared build/settings for all child images
###
FROM ruby:2.6.6-slim-stretch AS base

ARG userid=309
SHELL ["/bin/bash", "-c"]
RUN groupadd -g $userid -r gi-bill-data-service && \
    useradd -u $userid -r -g gi-bill-data-service -d /srv/gi-bill-data-service gi-bill-data-service
RUN apt-get update -qq && apt-get install -y \
    build-essential git curl libpq-dev dumb-init

RUN mkdir -p /srv/gi-bill-data-service/src && \
    chown -R gi-bill-data-service:gi-bill-data-service /srv/gi-bill-data-service
WORKDIR /srv/gi-bill-data-service/src

###
# development
#
# use --target=development to stop here
# this stage is used for local development with docker-compose.yml
###
FROM base AS development
RUN curl -L -o /usr/local/bin/cc-test-reporter https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 && \
    chmod +x /usr/local/bin/cc-test-reporter && \
    cc-test-reporter --version

COPY --chown=gi-bill-data-service:gi-bill-data-service docker-entrypoint.sh ./
USER gi-bill-data-service
ENTRYPOINT ["/usr/bin/dumb-init", "--", "./docker-entrypoint.sh"]

###
# builder
#
# use --target=builder to stop here
# this stage copies the app and is used for running tests/lints/stuff
# usually run via the docker-compose.test.yml
###
FROM development AS builder

ENV BUNDLER_VERSION='2.2.11'

ARG bundler_opts
COPY --chown=gi-bill-data-service:gi-bill-data-service . .
USER gi-bill-data-service
RUN gem install bundler --no-document -v ${BUNDLER_VERSION}
RUN bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin" $bundler_opts && find ${BUNDLE_APP_CONFIG}/cache -type f -name \*.gem -delete
ENV PATH="/usr/local/bundle/bin:${PATH}"

###
# production
#
# default target
# this stage is used in live environmnets
###
FROM base AS production

ENV RAILS_ENV="production"
ENV PATH="/usr/local/bundle/bin:${PATH}"
COPY --from=builder $BUNDLE_APP_CONFIG $BUNDLE_APP_CONFIG
COPY --from=builder --chown=gi-bill-data-service:gi-bill-data-service /srv/gi-bill-data-service/src ./
USER gi-bill-data-service

ENTRYPOINT ["/usr/bin/dumb-init", "--", "./docker-entrypoint.sh"]
