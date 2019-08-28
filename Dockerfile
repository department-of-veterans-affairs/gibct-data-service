FROM ruby:2.4.5-slim-stretch

# Match the jenkins uid/gid on the host (504)
RUN groupadd -r gibct && \
    useradd -r -g gibct gibct && \
    apt-get update -qq && \
    apt-get install -y build-essential \
    git \
    libpq-dev \
    libgmp-dev \
    clamav \
    imagemagick \
    pdftk \
    poppler-utils && \
    freshclam

RUN ["/bin/bash", "--login", "-c", "gem install --no-doc bundler"]

# Configure gibct application
RUN mkdir -p /src/gibct && chown gibct:gibct /src/gibct
VOLUME /src/gibct
WORKDIR /src/gibct

ADD . /src/gibct
RUN ["/bin/bash", "--login", "-c", "bundle install -j4"]
