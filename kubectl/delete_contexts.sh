#!/bin/bash

source $(dirname $BASH_SOURCE)/../utils/user_confirm.sh

kubectl_delete_contexts() {
    contexts=$(kubectl config get-contexts | sed -E "s/\s+/~/g" | cut -f 2 -d "~" | grep -v NAME)

    if [[ $contexts == "" ]]; then
        echo "No contexts in the current kubectl config."
        return
    fi

    echo -e "You are about to delete the following contexts:\n"
    echo $contexts | tr " " "\n"
    if user_confirm; then
        for context in $contexts; do kubectl config delete-context $context; done
    fi
}
