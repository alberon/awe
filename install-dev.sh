#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

if [ -d $HOME/local/bin ]; then
    # Assume ~/bin is version controlled and ~/local/bin is not
    # https://github.com/alberon/dotfiles
    ln -s $PWD/bin/awe $HOME/local/bin/awe-dev
    echo "Installed in ~/local/bin/awe-dev"
elif [ -d $HOME/bin ]; then
    ln -s $PWD/bin/awe $HOME/bin/awe-dev
    echo "Installed in ~/bin/awe-dev"
else
    echo "Neither ~/bin nor ~/local/bin exist" >&2
    exit 1
fi
