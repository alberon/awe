#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

rm -rf docs-html/
sphinx-build docs/ docs-html/
sphinx-autobuild -H 0.0.0.0 docs/ docs-html/
