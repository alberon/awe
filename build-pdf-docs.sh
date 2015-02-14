#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

rm -rf docs-pdf/
sphinx-build -b latex docs/ docs-pdf/
make -C docs-pdf/ all-pdf
