FROM ruby:2.5.7-alpine3.10 AS build
RUN set -eux; apk add --no-cache build-base git tzdata postgresql-dev nodejs

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --retry 3 --jobs 10 --without development test

COPY . ./
RUN bundle exec rake \ 
    DATABASE_HOST=postgres DATABASE_PORT=5444 \ 
    GC_DATABASE=gc GC_DATABASE_USERNAME=gc GC_DATABASE_PASSWORD=gc \
    assets:precompile \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete \
    && rm -rf /usr/local/bundle/cache/*.gem 

FROM ruby:2.5.7-alpine3.10
RUN set -eux; apk add --no-cache tzdata postgresql-dev nodejs \
    && addgroup -g 10001 -S appuser \
    && adduser -u 10001 -S appuser -G appuser

WORKDIR /app
COPY --from=build --chown=appuser:appuser /app /app
COPY --from=build /usr/local/bundle /usr/local/bundle

EXPOSE 3000

VOLUME /app/log /app/tmp/ /app/db

USER appuser

ENV RAILS_ENV=production SECRET_KEY_BASE=long-secret-key

CMD bundle exec rails server -b 0.0.0.0
