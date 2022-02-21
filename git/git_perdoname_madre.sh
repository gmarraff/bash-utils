#!/bin/bash

git_perdoname_madre_forced() {
    git add .
    git commit --amend --no-edit
    git push -f
}

git_perdoname_madre() {
    echo "You are about to force amending and force pushing the commit."
    read -p "Continue [y/N]? " answer
    if [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "yes" ]]; then
        git_perdoname_madre
    else
        echo "$USERNAME said no, aborted."
    fi
}
