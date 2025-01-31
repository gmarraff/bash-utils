#!/bin/bash

CURRENT_DIR=$(dirname $BASH_SOURCE)

chmod +x $CURRENT_DIR/bins/*
mkdir -p $HOME/.local/bin
ln -sf $CURRENT_DIR/bins/* $HOME/.local/bin
