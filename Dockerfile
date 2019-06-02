FROM ruby:2.5.0-alpine

RUN apk add --no-cache --update --virtual .build-deps \
        build-base \
        postgresql-dev \
        linux-headers \
        git && \
    # Runtime dependencies, keep them after build
    apk add --no-cache --update \
        tzdata \
        libpq \
        nodejs

# Copy it before the application, allowing an easier
# caching of dependencies in docker layers
COPY Gemfile* /tmp/

RUN cd /tmp && \
    bundle update factory_bot && \
    bundle install && \
    apk del .build-deps

WORKDIR /opt/gorgeous-code-assessment
COPY . /opt/gorgeous-code-assessment

# RUN rake assets:precompile
CMD ["rails", "server", "-b", "0.0.0.0"]
