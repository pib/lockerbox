#!/bin/bash

#### Config

NODE_DOWNLOAD='http://nodejs.org/dist/node-v0.4.8.tar.gz'

#### Setup

PWD=`pwd`
OK=true

#### Helper functions

function check_for {
    version=`$2 2>&1 | grep -o [0-9.]*`
    if [ -z "$version" ]; then
        echo "$1 not found!" >&2
        OK=false
    else
        echo "$1 version $version found." >&2
    fi
}

function download {
    cd build
    base=`basename $1`
    if [ -f $base ]; then
        echo "$1 already downloaded." >&2
    else
        if wget "$1" || curl -o $base "$1"; then
            echo "Downloaded $1." >&2
        else
            echo "Download of $1 failed!" >&2
            exit
        fi
    fi
}

#### Main script

check_for Git 'git --version'
check_for Python 'python -V'

mkdir -p build
download "$NODE_DOWNLOAD"