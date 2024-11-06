#!/bin/bash

function deploy_pull_secrets_from_file {
    namespace=$1
    secretName=$2
    dockerAuthFile=$3
    overwrite=$4

    if [ -z "$namespace" ] || [ -z "$secretName" ] || [ -z "$dockerAuthFile" ]; then
        echo "Error: All positional arguments (namespace, secretName, dockerAuthFile) must be provided."
        return 1
    fi

    if [[ "$overwrite" == "--overwrite" ]]; then
        kubectl -n $namespace delete secret $secretName
    fi

    kubectl create secret generic $secretName \
        --from-file=.dockerconfigjson=$dockerAuthFile \
        --type=kubernetes.io/dockerconfigjson \
        --namespace=$namespace
}
