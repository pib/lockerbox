#!/bin/bash

#### Config

NODE_DOWNLOAD='http://nodejs.org/dist/node-v0.4.8.tar.gz'
NPM_DOWNLOAD='http://npmjs.org/install.sh'
VIRTUALENV_DOWNLOAD='http://github.com/pypa/virtualenv/raw/develop/virtualenv.py'
MONGODB_DOWNLOAD='http://fastdl.mongodb.org/linux/mongodb-OS-ARCH-1.8.1.tgz'

LOCKER_REPO='https://github.com/quartzjer/Locker.git'
LOCKER_BRANCH='dev'

#### Setup

OK=true

#### Helper functions

# check_for name version_command [minimum_version [optional]]
function check_for {
    version=`$2 2>&1 | grep -o [-0-9.]* | head -n 1`
    if [ -z "$version" ]; then
        echo "$1 not found!" >&2
        OK=false
    else
        echo "$1 version $version found." >&2
    fi
    if [ -n "$3" ]; then
        if [ "$version" \< "$3" ]; then
            echo "$1 version $3 or greater required!" >&2
            if [ -z "$4" ]; then
                exit 1
            else
                false
            fi
        fi
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
            exit 1
        fi
    fi
}

#### Main script
BASEDIR=`pwd`

if [ "$0" != "lockerbox.sh" -a "$1" != "lockerbox.sh" ]; then
    BASEDIR="$BASEDIR/lockerbox"
    mkdir -p "$BASEDIR"
    cd "$BASEDIR"
fi

export PRE_LOCKERBOX_PATH=$PATH
export PATH="$BASEDIR/bin":$PATH
export PRE_LOCKERBOX_NODE_PATH=$NODE_PATH
export NODE_PATH="$BASEDIR/lib":$NODE_PATH

check_for Git 'git --version'
check_for Python 'python -V' 2.6

mkdir -p build
cd build

check_for Node.js 'node -v' 0.4.8 optional

if [ $? -ne 0 ]; then
    echo "" >&2
    echo "About to download, build, and install locally node.js." >&2
    echo -n "This could take a while." >&2
    sleep 1; echo -n .; sleep 1; echo -n .; sleep 1; echo -n .; sleep 1
    download "$NODE_DOWNLOAD"
    if tar zxf "`basename \"$NODE_DOWNLOAD\"`" &&
        cd `basename "$NODE_DOWNLOAD" .tar.gz` &&
        ./configure --prefix="$BASEDIR" &&
        make &&
        make install
    then
        echo "Installed node.js into $BASEDIR" >&2
    else
        echo "Failed to install node.js into $BASEDIR" >&2
        exit 1
    fi
fi

cd "$BASEDIR/build"
check_for npm "npm -v" 1 optional

if [ $? -ne 0 ]; then
    echo "" >&2
    echo "About to download and install locally npm." >&2
    download "$NPM_DOWNLOAD" 
    clean=no
    if sh `basename $NPM_DOWNLOAD`; then
        echo "Installed npm into $BASEDIR" >&2
    else
        echo "Failed to install npm into $BASEDIR" >&2
        exit 1
    fi
fi

check_for virtualenv "virtualenv --version" 1.4 optional

if [ $? -ne 0 ]; then
  echo "" >&2
  echo "About to download virtualenv.py." >&2
  download "$VIRTUALENV_DOWNLOAD"
fi

if find "$BASEDIR/bin/activate" >/dev/null 2>&1 || python -m virtualenv --no-site-packages "$BASEDIR" &&
    source "$BASEDIR/bin/activate"
then
    echo "Set up virtual environment." >&2
else
    echo "Failed to set up virtual environment." >&2
fi

check_for mongoDB "mongod --version" 1.9.1 optional

if [ $? -ne 0 ]; then
    OS=`uname -s`
    case $OS in
        Linux)
            OS=linux
            ;;
        Darwin)
            OS=osx
            ;;
        *)
            echo "Don't recognize OS $OS" >&2
            exit 1
    esac
    ARCH=`uname -p`
    echo "" >&2
    echo "Downloading and installing locally mongoDB" >&2
    MONGODB_DOWNLOAD=`echo $MONGODB_DOWNLOAD | sed -e "s/OS/$OS/" -e "s/ARCH/$ARCH/"`
    download $MONGODB_DOWNLOAD
    if tar zxf `basename "$MONGODB_DOWNLOAD"` &&
        cp `basename "$MONGODB_DOWNLOAD" .tgz`/bin/* "$BASEDIR/bin"
    then
        echo "Installed local mongoDB." >&2
    else
        echo "Failed to install local mongoDB." >&2
        exit 1
    fi
fi

cd "$BASEDIR"

