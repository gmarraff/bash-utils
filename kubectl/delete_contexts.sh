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

helm_delete_releases() {
    namespace=${1:-default}
    pattern=${2:-.+}

    releases=$(helm -n $namespace list | grep -v NAME | awk '{print $1}' | grep -E "$pattern")
    if [[ $releases == "" ]]; then
        echo "No releases found in namespace $namespace."
        return
    fi

    echo -e "You are about to delete the following releases:\n"
    echo $releases | tr " " "\n"

    if user_confirm; then
        echo $releases | tr " " "\n" | xargs helm uninstall
    fi
}
