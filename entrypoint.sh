#!/bin/sh

# obviously you wouldn't setup the db everytime like this normally, best thing to do is to migrate only when necessary,
# one example is to use helm hooks:
# post-install -> init db
# post-upgrade -> migrate db
# execute these hooks as one-time Job objects
bundle exec rake assets:precompile
bundle exec rake db:migrate
bundle exec rails server -b 0.0.0.0
