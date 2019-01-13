FROM ruby:2.5-alpine
ENV TZ Europe/Berlin
RUN \
  mkdir -p /app \
  && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
  && echo "${TZ}" > /etc/timezone \
  && addgroup -S freeletics \
  && adduser -S -D -h /app -s /sbin/nologin -G freeletics freeletics
RUN \
  apk add --no-cache --virtual .build-deps \
      build-base \
      automake \
      autoconf \
      postgresql-dev \
      dbus \
      git \
      qt-dev \
      nodejs
# RUN apt update && apt upgrade -y && apt install nodejs -y
WORKDIR /app
COPY Gemfile /app
COPY Gemfile.lock /app
RUN bundle install
COPY . /app
RUN chown freeletics:freeletics -R /app
USER freeletics

