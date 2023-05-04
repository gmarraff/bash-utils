#/!bin/bash

WORKDIR=$(dirname $BASH_SOURCE)
DIRECTORIES="
bins
git
kubectl
mark
misc
"

for dir in $DIRECTORIES; do
    for file in  $WORKDIR/$dir/*.sh; do
        source $file
    done
done
