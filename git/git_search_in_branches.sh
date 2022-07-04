#!/bin/bash

git_search_in_branches_print_help() {
    echo """
USAGE:
    git_search_in_branches PATTERN [PATH] [BRANCHES]
        PATTERN -> String to search for (you can prepend extra flag, eg: -E .*)
        PATH -> Path were to search for in branches
        BRANCHES -> Branch pattern to be parsed by grep to search for only for some branches
    """
}

git_search_in_branches() {
    pattern=$1
    path=$2
    branches=$3

    if [[ -z "$pattern" ]]; then
        echo "Please specify a pattern to search for."
        git_search_in_branches_print_help
        return
    fi

    pathspec=""
    if [[ "$path" != "" ]]; then
        pathspec="-- $path"
    fi

    revisions=$(git branch -a --format='%(refname:short)' | grep -v "\->")
    if [[ "$branches" != "" ]]; then
        revisions=$(echo $revisions | tr " " "\n" | grep $branches | tr "\n" " ")
    fi
    git grep "$pattern" $revisions $pathspec
}
