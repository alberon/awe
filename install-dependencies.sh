#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# Install Composer dependencies (locally)
# TODO

# Install Ruby dependencies (locally)
bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --deployment

# Install Python dependencies? (locally or globally?)
# TODO
