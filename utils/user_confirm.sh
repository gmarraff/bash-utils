#!/bin/bash

user_confirm() {
    echo -e $1
    read -p "Continue [y/N]? " answer
    if [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "yes" ]]; then
        return 0
    else
        echo "$USERNAME said no, exiting."
        return 1
    fi
}
