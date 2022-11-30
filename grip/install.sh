#!/bin/bash

DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ -f /usr/bin/grip-hook ]]; then
    rm /usr/bin/grip-hook
fi
ln -s $DIR/grip-hook /usr/bin/grip-hook

if [[ -f /usr/share/icons/markdown.png ]]; then
    rm /usr/share/icons/markdown.png
fi
mkdir -p /usr/share/icons
install $DIR/markdown.png /usr/share/icons

if [[ -f /usr/share/applications/grip-hook.desktop ]]; then
    rm /usr/share/applications/grip-hook.desktop
fi
install $DIR/grip-hook.desktop /usr/share/applications/grip-hook.desktop
