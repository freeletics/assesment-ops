FROM ruby:2.5.0-alpine
ADD  Gemfile /app/
ADD  Gemfile.lock /app/
RUN  apk --update add --no-cache git ruby-dev libpq build-base postgresql-dev
RUN  gem install bundler --no-ri --no-rdoc && \
     cd /app ; bundle install
ADD  . /app
RUN  chown -R nobody:nogroup /app
USER nobody
WORKDIR /app

