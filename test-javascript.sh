#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# Clear the screen to hide previous runs, making it easier to see the red/green
# status at a glance (especially when running test-watch.sh)
clear

# Run the tests
cd javascript
if [ $# -gt 0 ]; then
    exec ../node_modules/.bin/mocha --bail --reporter=spec --require=coffee-script/register "$@"
else
    exec ../node_modules/.bin/mocha --bail --reporter=spec --require=coffee-script/register test/**
fi
