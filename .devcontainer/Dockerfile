# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.1
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Install packages needed to build gems
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  libpq-dev libvips \
  #  For video thumbnails
  ffmpeg \
  # For pdf thumbnails. If you want to use mupdf instead of poppler,
  poppler-utils
