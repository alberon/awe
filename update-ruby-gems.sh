#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --no-deployment
bundle update
