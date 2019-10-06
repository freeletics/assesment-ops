FROM ruby:2.5.5-alpine3.9
RUN mkdir /freeletics
WORKDIR /freeletics 
RUN apk add --no-cache --update \
  git \
  build-base \
  postgresql-dev \
  nodejs
ARG RELEASE_BRANCH
# this invalidates the cache so that git clone pulls latest code always!!
# pass git credentials while building image
RUN echo $(date) > time.txt
RUN git clone https://github.com/freeletics/test-ops.git --branch $RELEASE_BRANCH --single-branch
#COPY . .
RUN bundle install
CMD rails server -b 0.0.0.0