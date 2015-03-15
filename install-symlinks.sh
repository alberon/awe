#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")"

# TODO: Convert this script to PHP so it can be properly unit tested?

source bash/ask.bash

# Check if link exists
link_exists() {
    [ -e "$1" -o -L "$1" ]
}

# Install symlinks
install() {
    local link="$1"
    local target="$2"

    # Warn if the file exists but doesn't point to the target file already
    # -e test for existing files, -L then tests for broken symlinks
    if link_exists "$link"; then
        local link_real="$(readlink -f "$link")"
        local target_real="$(readlink -f "$target")"

        if [ "$link_real" = "$target_real" ]; then
            # Nothing to do
            echo "$link already exists (=> $target)"
            return
        fi

        ask "$link exists (=> $link_real) - overwrite?" || return
        sudo rm -rf "$link"
    fi

    # Create the link
    sudo ln -s "$target" "$link"
    echo "Installed $link (=> $target)"
}

# Uninstall symlinks
uninstall() {
    local link="$1"
    local target="$2"

    # Make sure the link exists
    if ! link_exists "$link"; then
        echo "$link doesn't exist"
        return
    fi

    # Make sure it's pointing to the right file, so we don't remove the wrong thing
    local link_real="$(readlink -f "$link")"
    local target_real="$(readlink -f "$target")"

    if [ "$link_real" != "$target_real" ]; then
        ask "$link points to $link_real (expected $target) - remove anyway?" N || return
    fi

    # Remove the link
    sudo rm -f "$link"
    echo "Removed $link"
}

# Use the same script to uninstall to avoid duplication
action=install
if [ "${1:-}" = "--uninstall" ]; then
    action=uninstall
fi

# The user will need sudo rights, so let's ensure they have them now
sudo true

# These are the same locations that npm uses...
# TODO: Maybe /usr/local would be better?
$action /usr/bin/awe $PWD/bin/awe
$action /usr/share/man/man1/awe.1 $PWD/man-build/awe.1
