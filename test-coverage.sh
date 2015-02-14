#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

php -d xdebug.coverage_enable=On vendor/bin/phpunit --coverage-html test-coverage "$@"
