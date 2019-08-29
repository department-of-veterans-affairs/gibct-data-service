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
    curl \
    poppler-utils && \
    freshclam

# install phantomjs
RUN apt-get install -y libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev libstdc++ && \
  curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  mkdir -p /opt/phantomjs && \
  tar -xjvf ./phantomjs-2.1.1-linux-x86_64.tar.bz2 --strip-components 1 -C /opt/phantomjs/ && \
  ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs

RUN ["/bin/bash", "--login", "-c", "gem install --no-doc bundler"]

# Configure gibct application
RUN mkdir -p /src/gibct && chown gibct:gibct /src/gibct
VOLUME /src/gibct
WORKDIR /src/gibct

ADD . /src/gibct
RUN ["/bin/bash", "--login", "-c", "bundle install -j4"]
