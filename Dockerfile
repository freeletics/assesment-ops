# Slim version of ruby
FROM ruby:2.5.0-slim

# Debconf 
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install some packages
RUN apt-get update -yqq \
	&& apt-get install -yqq \
		build-essential \
		libpq-dev \
		postgresql-client \
		git \
		nodejs

# Setup directory
RUN mkdir /test-ops
WORKDIR /test-ops
COPY Gemfile* ./
RUN gem install bundler && bundle install
COPY . ./

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ['entrypoint.sh']

# Port 3000 so app can be accessed
EXPOSE 3000

# Start the rails app
CMD ['bundle', 'exec', 'rails', 'server', '-b', '0.0.0.0']


