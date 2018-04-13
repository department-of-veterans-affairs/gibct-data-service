FROM centos:6

# Match the jenkins uid/gid on the host (504)
RUN groupadd -r gibct && \
      useradd -r -g gibct gibct

RUN yum install -y git make gcc-c++ openssl-devel readline-devel zlib-devel sqlite-devel postgresql-devel socat timeout epel-release nc

# Install Red Hat SCI library for ruby packages
RUN yum install -y centos-release-scl-rh
RUN yum install -y rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygems
RUN echo "source /opt/rh/rh-ruby23/enable" > /etc/profile.d/rh-ruby23.sh
RUN ["/bin/bash", "--login", "-c", "gem install --no-doc bundler"]

# Configure gibct application
RUN mkdir -p /src/gibct && chown gibct:gibct /src/gibct
VOLUME /src/gibct
WORKDIR /src/gibct

ADD Gemfile /src/gibct/Gemfile
ADD Gemfile.lock /src/gibct/Gemfile.lock
RUN ["/bin/bash", "--login", "-c", "bundle install -j4"]

ADD . /src/gibct
