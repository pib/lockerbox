#!/bin/bash

#### Config

NODE_DOWNLOAD='http://nodejs.org/dist/node-v0.4.8.tar.gz'

#### Setup

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
BASEDIR=`pwd`

check_for Git 'git --version'
check_for Python 'python -V'

mkdir -p build
cd build
download "$NODE_DOWNLOAD"
echo -n "About to build node.js. This could take a while." >&2
sleep 1; echo -n .; sleep 1; echo -n .; sleep 1; echo -n .; sleep 1
if tar zxf "`basename \"$NODE_DOWNLOAD\"`" &&
    cd `basename "$NODE_DOWNLOAD" .tar.gz` &&
    ./configure --prefix="$BASEDIR" &&
    make &&
    make install
then
    echo "Installed node.js into $BASEDIR" >&2
else
    echo "Failed to install node.js into $BASEDIR" >&2
fi
cd ..