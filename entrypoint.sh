#/!bin/bash

WORKDIR=$(dirname $BASH_SOURCE)
DIRECTORIES="
git
kubectl
"

for dir in $DIRECTORIES; do
    for file in  $WORKDIR/$dir/*.sh; do
        source $file
    done
done
