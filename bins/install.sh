#!/bin/bash

CURRENT_DIR=$(dirname $BASH_SOURCE)

chmod +x $CURRENT_DIR/bins/*
ln -sf $CURRENT_DIR/bins/* $HOME/.local/bin
