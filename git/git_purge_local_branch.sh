#!/bin/bash

source $(dirname $BASH_SOURCE)/../utils/user_confirm.sh

# Prune the branches deleted on the remote and then remove them
# from the local git repository, after asking for confirmation.
git_purge_local_branches() {
    if ! git rev-parse --is-inside-work-tree >/dev/null; then
        return
    fi
    git remote prune origin
    gone_branches=$(git branch -v | grep -F [gone] | awk '{print $1}')
    echo -e "\nLocal branches to delete:\n"
    if [ -z "$gone_branches" ]; then
        echo "No local branches to delete found"
    else
        echo $gone_branches | tr " " "\n"
        if user_confirm; then
            echo $gone_branches | xargs git branch -D
        fi
    fi
}
