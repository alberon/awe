#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

rm -rf man-build/
mkdir man-build/
node_modules/marked-man/bin/marked-man --manual="Awe Manual" man/awe.1.md > man-build/awe.1

if [ "${1:-}" != "-q" ]; then
    # Display the man page
    exec man man-build/awe.1
fi
