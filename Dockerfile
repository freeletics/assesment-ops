FROM ruby:2.5

RUN apt update && apt upgrade -y && apt install nodejs -y

RUN mkdir /app

# Install gems
ADD Gemfile* /app/
WORKDIR /app
RUN bundle install

# Add application
ADD . /app


