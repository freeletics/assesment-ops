#!/bin/bash
set -e

# Setup DB
/test-ops/bin/setup

# Run process in docker CMD
bundle exec "$@"