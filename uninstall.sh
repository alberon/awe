#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

./install-symlinks.sh --uninstall
