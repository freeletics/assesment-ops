FROM ruby:2.5-alpine
ENV TZ Europe/Berlin
RUN \
  mkdir -p /app \
  && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
  && echo "${TZ}" > /etc/timezone \
  && addgroup -S freeletics \
  && adduser -S -D -h /app -s /sbin/nologin -G freeletics freeletics \
  && apk add --no-cache --virtual .build-deps \
      build-base \
      postgresql-dev \
      git \
      nodejs
WORKDIR /app
COPY --chown=freeletics:freeletics Gemfile* /app/
RUN bundle install
COPY --chown=freeletics:freeletics . /app/
USER freeletics

