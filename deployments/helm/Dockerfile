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

#Workdir configuration
WORKDIR /usr/bin/app
RUN gem install bundler

# App dependencies
COPY Gemfile* ./

# Install app dependencies
RUN bundle install \
    --deployment \
    --clean \
    --jobs 8 \
    --retry 5 \
    --without development test 

# Ports
EXPOSE 3000

# Rest of the app configuration
COPY . ./

# Rails env.
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

RUN chmod +x /usr/bin/app/entrypoint.sh && \
    chown -R nobody:nogroup /usr/bin/app

USER nobody

ENTRYPOINT [ "entrypoint.sh" ]

# TODO: HEALTHCHECK?
#Alternatively, set metadata using --label flag while building the image
# ARG COMMIT_SHA
# ARG BRANCH

# LABEL COMMIT_SHA=${COMMIT_SHA}
# LABEL BRANCH=${BRANCH}