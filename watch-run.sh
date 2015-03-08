#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# Make sure 'when-changed' is installed
source bash/require-when-changed.bash

# Run initial command in a subshell (to allow 'cd') and ignore failures
(eval "$@") || true

# Watch for further changes
exec when-changed -r fixtures javascript src templates tests -c "$*"
