FROM ruby:2.5.0

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

ENV APP_PATH /usr/src/app
ENV BUNDLER_VERSION 2.0.1
ENV RAILS_ENV production
ENV RACK_ENV production

RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH

RUN gem install bundler -v $BUNDLER_VERSION
RUN bundle config --global frozen 1

COPY Gemfile $APP_PATH
COPY Gemfile.lock $APP_PATH

RUN bundle install --clean \
                   --full-index \
                   --quiet \
                   --jobs 20 \
                   --retry 5 \
                   --without development test

COPY . $APP_PATH

EXPOSE 3000

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -f http://localhost:3000/ || exit 1

#NOT Implemented
ENV DATABASE_URL change.me.db.endpoint
ENV DATABASE_USER ror-user
ENV DATABASE_PASSWORD pass
ENV REDIS_ENDPOINT change.me.redis.endpoint


ENTRYPOINT ["bundle", "exec"]

CMD ["rails", "server", "-b", "0.0.0.0"]
