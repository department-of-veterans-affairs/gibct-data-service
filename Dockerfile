FROM ruby:2.4.5-slim-stretch AS base

# Match the jenkins uid/gid on the host (504)
RUN groupadd -r gibct && \
    useradd -r -g gibct -d /srv/gibct gibct

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    dumb-inint build-essential git curl clamav libpq-dev freshclam
# RUN groupadd -r gibct && \
#     useradd -r -g gibct gibct && \
#     apt-get update -qq && \
#     apt-get install -y build-essential \
#     git \
#     curl \
#     clamav \
#     libpq-dev && \
#     freshclam
RUN mkdir -p /srv/gibct/{clamav/database,pki/tls,secure,src} && \
    chown -R gibct:gibct /srv/gibct && \
    ln -s /srv/gibct/pki /etc/pki

COPY config/ca-trust/* /usr/local/share/ca-certificates/
RUN cd /usr/local/share/ca-certificates ; for i in *.pem ; do mv $i ${i/pem/crt} ; done ; update-ca-certificates
WORKDIR /srv/gibct/src


FROM base AS development

# install phantomjs
RUN apt-get install -y libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev libstdc++ && \
  curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  mkdir -p /opt/phantomjs && \
  tar -xjvf ./phantomjs-2.1.1-linux-x86_64.tar.bz2 --strip-components 1 -C /opt/phantomjs/ && \
  ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /cc-test-reporter
RUN chmod +x /cc-test-reporter

RUN ["/bin/bash", "--login", "-c", "gem install --no-doc bundler"]


FROM base as production

ENV RAILS_ENV=production
COPY --from=builder $BUNDLE_APP_CONFIG $BUNDLE_APP_CONFIG
COPY --from=builder --chown=gibct:gibct /srv/gibct/src ./
COPY --from=builder --chown=gibct:gibct /srv/gibct/clamav/database ../clamav/database
RUN if [ -d certs-tmp ] ; then cd certs-tmp ; for i in * ; do cp $i /usr/local/share/ca-certificates/${i/pem/crt} ; done ; fi && update-ca-certificates
USER gibct
ENTRYPOINT ["/usr/bin/dumb-init", "--", "./docker-entrypoint.sh"]

# Configure gibct application
# RUN mkdir -p /src/gibct && chown gibct:gibct /src/gibct
# VOLUME /src/gibct
# WORKDIR /src/gibct

# ADD . /src/gibct
# RUN ["/bin/bash", "--login", "-c", "bundle install -j4"]

# ENTRYPOINT ["/usr/bin/dumb-init", "--", "./docker-entrypoint.sh"]
