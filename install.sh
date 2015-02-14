#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# Install dependencies
./install-dependencies.sh
echo

# Generate man pages
./build-man-page.sh -q

# Install symlinks
./install-symlinks.sh
