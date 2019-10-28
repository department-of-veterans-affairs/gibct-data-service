FROM ruby:2.4.5-slim-stretch

# Match the jenkins uid/gid on the host (504)
RUN groupadd -r gibct && \
    useradd -r -g gibct gibct && \
    apt-get update -qq && \
    apt-get install -y build-essential \
    git \
    curl \
    clamav \
    libpq-dev && \
    freshclam

# install phantomjs
RUN apt-get install -y libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev libstdc++ && \
  curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  mkdir -p /opt/phantomjs && \
  tar -xjvf ./phantomjs-2.1.1-linux-x86_64.tar.bz2 --strip-components 1 -C /opt/phantomjs/ && \
  ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /cc-test-reporter
RUN chmod +x /cc-test-reporter

RUN ["/bin/bash", "--login", "-c", "gem install --no-doc bundler"]

# Configure gibct application
RUN mkdir -p /src/gibct && chown gibct:gibct /src/gibct
VOLUME /src/gibct
WORKDIR /src/gibct

ADD . /src/gibct
RUN ["/bin/bash", "--login", "-c", "bundle install -j4"]
RUN ["/bin/bash", "--login", "-c", "yarn install --check-files"]
