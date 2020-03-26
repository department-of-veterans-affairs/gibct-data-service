###
# base
###
FROM ruby:2.4.5-slim-stretch AS base

ARG userid=309
SHELL ["/bin/bash", "-c"]
RUN groupadd -g $userid -r gi-bill-data-service && \
    useradd -u $userid -r -g gi-bill-data-service -d /srv/gi-bill-data-service gi-bill-data-service
RUN apt-get update -qq && apt-get install -y \
    build-essential git curl clamav libpq-dev dumb-init
RUN freshclam
RUN mkdir -p /srv/gi-bill-data-service/src && \
    chown -R gi-bill-data-service:gi-bill-data-service /srv/gi-bill-data-service
WORKDIR /srv/gi-bill-data-service/src

###
# development
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
###
FROM development AS builder

COPY --chown=gi-bill-data-service:gi-bill-data-service . .
USER gi-bill-data-service
RUN bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin" && find ${BUNDLE_APP_CONFIG}/cache -type f -name \*.gem -delete
ENV PATH "/usr/local/bundle/bin:${PATH}"

###
# production
###
FROM base AS production

ENV RAILS_ENV="production"
ENV PATH="/usr/local/bundle/bin:${PATH}"
COPY --from=builder $BUNDLE_APP_CONFIG $BUNDLE_APP_CONFIG
COPY --from=builder --chown=gi-bill-data-service:gi-bill-data-service /srv/gi-bill-data-service/src ./
COPY --from=builder --chown=gi-bill-data-service:gi-bill-data-service /var/lib/clamav /var/lib/clamav
RUN chown -R gi-bill-data-service:gi-bill-data-service .
USER gi-bill-data-service
ENTRYPOINT ["/usr/bin/dumb-init", "--", "./docker-entrypoint.sh"]
