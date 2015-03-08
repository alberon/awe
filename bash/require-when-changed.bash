if ! command -v when-changed >/dev/null 2>&1; then
    source bash/ask.bash
    if ask "Cannot find 'when-changed' - attempt to install it (sudo pip install ...)?" N; then
        sudo pip install --upgrade https://github.com/joh/when-changed/archive/master.zip
        # To remove it later (note: doesn't remove dependencies):
        # sudo pip uninstall when-changed
    else
        exit 1
    fi
fi

