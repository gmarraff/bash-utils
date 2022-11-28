#!/bin/bash

DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ ! -f /usr/bin/grip-hook ]]; then
    ln -s $DIR/grip-hook /usr/bin/grip-hook
fi
if [[ ! -f /usr/share/icons ]]; then
    mkdir -p /usr/share/icons
    install $DIR/markdown.png /usr/share/icons
fi
if [[ ! -f /usr/share/applications/grip-hook.desktop ]]; then
    install $DIR/grip-hook.desktop /usr/share/applications/grip-hook.desktop
fi
