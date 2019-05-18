FROM ruby:2.5.5-alpine

# Metadata
MAINTAINER anil@test.com

# OS-level dependencies
RUN apk add --no-cache --update \
    build-base \
    linux-headers \
    git \
    postgresql-dev \
    nodejs \
    tzdata

WORKDIR /usr/bin/app

RUN gem install bundler

COPY Gemfile* ./

# Install app dependencies
RUN bundle install \
    --jobs 8 \
    --retry 5 \
    --without production

# Ports
EXPOSE 3000

