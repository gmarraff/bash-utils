#/!bin/bash

WORKDIR=$(dirname $BASH_SOURCE)
DIRECTORIES="
git
"

for dir in $DIRECTORIES; do
    for file in  $WORKDIR/$dir/*.sh; do
        source $file
    done
done
