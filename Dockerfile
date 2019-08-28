FROM ruby:2.4.5-slim-stretch

# Match the jenkins uid/gid on the host (504)
RUN groupadd -r gibct && \
      useradd -r -g gibct gibct

#RUN yum install -y git make gcc-c++ openssl-devel readline-devel zlib-devel sqlite-devel postgresql-devel socat timeout epel-release nc

# Install Red Hat SCI library for ruby packages
#RUN yum install -y centos-release-scl-rh
#RUN yum install -y rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygems
#RUN echo "source /opt/rh/rh-ruby23/enable" > /etc/profile.d/rh-ruby23.sh
#RUN ["/bin/bash", "--login", "-c", "gem install --no-doc bundler"]

# install phantomjs
#RUN yum install -y fontconfig freetype freetype-devel fontconfig-devel libstdc++ && \
#  curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
#  mkdir -p /opt/phantomjs && \
#  tar -xjvf ./phantomjs-2.1.1-linux-x86_64.tar.bz2 --strip-components 1 -C /opt/phantomjs/ && \
#  ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs

# Configure gibct application
RUN mkdir -p /src/gibct && chown gibct:gibct /src/gibct
VOLUME /src/gibct
WORKDIR /src/gibct

#ADD Gemfile /src/gibct/Gemfile
#ADD Gemfile.lock /src/gibct/Gemfile.lock

ADD . /src/gibct
RUN ["/bin/bash", "--login", "-c", "bundle install -j4"]
