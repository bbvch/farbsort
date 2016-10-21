#!/bin/bash
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "Script needs to be sourced."
    exit 1
fi

source sources/poky/oe-init-build-env build
