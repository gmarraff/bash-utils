#!/bin/bash

source $(dirname $BASH_SOURCE)/../utils/user_confirm.sh

git_perdoname_madre_forced() {
    git add .
    git commit --amend --no-edit
    git push -f
}

git_perdoname_madre() {
    if user_confirm "You are about to force amending and force pushing the commit."; then
        git_perdoname_madre_forced
    fi
}
