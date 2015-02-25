#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

rm -f $HOME/bin/awe-dev
rm -f $HOME/local/bin/awe-dev
