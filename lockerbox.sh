#!/bin/bash

#### Config

NODE_DOWNLOAD='http://nodejs.org/dist/node-v0.4.8.tar.gz'
NPM_DOWNLOAD='http://npmjs.org/install.sh'
VIRTUALENV_DOWNLOAD='http://github.com/pypa/virtualenv/raw/develop/virtualenv.py'
MONGODB_DOWNLOAD='http://fastdl.mongodb.org/OS/mongodb-OS-ARCH-1.8.1.tgz'
LOCKERBOX_DOWNLOAD='https://raw.github.com/pib/lockerbox/master/lockerbox.sh'

LOCKER_REPO='https://github.com/LockerProject/Locker.git'
LOCKER_BRANCH='master'

#### Helper functions

# check_for name exec_name version_command [minimum_version [optional]]
function check_for {
    found=`which $2`
    version=`$3 2>&1 | grep -o "[-0-9.]*" | head -n 1`
    if [ -z "$found" ]; then
        echo "$1 not found!" >&2
    else
        echo "$1 version $version found." >&2
        if [ -z "$4" ]; then
            return
        fi
    fi
    if [ -n "$4" ]; then
        if [ "$version" \< "$4" ]; then
            echo "$1 version $4 or greater required!" >&2
            if [ -z "$5" ]; then
                exit 1
            else
                false
            fi
        fi
    else
        exit 1
    fi
}

function download {
    base=`basename $1`
    echo $base
    if [ -f $base ]; then
        echo "$1 already downloaded." >&2
    else
        if wget "$1" 2>/dev/null || curl -L -o $base "$1"; then
            echo "Downloaded $1." >&2
        else
            echo "Download of $1 failed!" >&2
            exit 1
        fi
    fi
}

#### Main script
BASEDIR=`pwd`

echo $0 $1
if [ "$0" != "./lockerbox.sh" -a "$1" != "lockerbox.sh" ]; then
    mkdir -p "$BASEDIR/lockerbox"
    cd "$BASEDIR/lockerbox"
    download "$LOCKERBOX_DOWNLOAD"
    chmod 755 lockerbox.sh
    exec ./lockerbox.sh
fi

export PYEXE=`which python`

export PRE_LOCKERBOX_PATH=$PATH
export PATH="$BASEDIR/local/bin":$PATH
export PRE_LOCKERBOX_NODE_PATH=$NODE_PATH
export NODE_PATH="$BASEDIR/local/lib/node_modules":$NODE_PATH

check_for Git git 'git --version'
check_for Python python 'python -V' 2.6

mkdir -p local/build
cd local/build

check_for Node.js node 'node -v' 0.4.8 optional

if [ $? -ne 0 ]; then
    echo "" >&2
    echo "About to download, build, and install locally node.js." >&2
    echo -n "This could take a while." >&2
    sleep 1; echo -n .; sleep 1; echo -n .; sleep 1; echo -n .; sleep 1
    download "$NODE_DOWNLOAD"
    if tar zxf "`basename \"$NODE_DOWNLOAD\"`" &&
        cd `basename "$NODE_DOWNLOAD" .tar.gz` &&
        ./configure --prefix="$BASEDIR/local" &&
        make &&
        make install
    then
        echo "Installed node.js into $BASEDIR" >&2
    else
        echo "Failed to install node.js into $BASEDIR" >&2
        exit 1
    fi
fi

cd "$BASEDIR/local/build"
check_for npm npm "npm -v" 1 optional

if [ $? -ne 0 ]; then
    echo "" >&2
    echo "About to download and install locally npm." >&2
    download "$NPM_DOWNLOAD" 
    if cat `basename $NPM_DOWNLOAD` | clean=no sh; then
        echo "Installed npm into $BASEDIR" >&2
    else
        echo "Failed to install npm into $BASEDIR" >&2
        exit 1
    fi
fi

if ! find "$BASEDIR/local/bin/activate" >/dev/null 2>&1; then
    check_for virtualenv virtualenv "virtualenv --version" 1.4 optional

    if [ $? -ne 0 ]; then
        echo "" >&2
        echo "About to download virtualenv.py." >&2
        download "$VIRTUALENV_DOWNLOAD"
    fi
    if $PYEXE -m virtualenv --no-site-packages "$BASEDIR/local"; then
        echo "Set up virtual Python environment." >&2
    else
        echo "Failed to set up virtual Python environment." >&2
    fi
fi

if source "$BASEDIR/local/bin/activate"; then
    echo "Activated virtual Python environment." >&2
else
    echo "Failed to activate virtual Python environment." >&2
fi

check_for mongoDB mongod "mongod --version" 1.8.1 optional

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
    ARCH=`uname -m`
    echo "" >&2
    echo "Downloading and installing locally mongoDB" >&2
    MONGODB_DOWNLOAD=`echo $MONGODB_DOWNLOAD | sed -e "s/OS/$OS/g" -e "s/ARCH/$ARCH/g"`
    download $MONGODB_DOWNLOAD
    if tar zxf `basename "$MONGODB_DOWNLOAD"` &&
        cp `basename "$MONGODB_DOWNLOAD" .tgz`/bin/* "$BASEDIR/local/bin"
    then
        echo "Installed local mongoDB." >&2
    else
        echo "Failed to install local mongoDB." >&2
        exit 1
    fi
fi

cd "$BASEDIR"

if [ ! -d Locker/.git ]; then
    echo "Checking out Locker repo." >&2
    if git clone "$LOCKER_REPO" -b "$LOCKER_BRANCH"; then
        echo "Checked out Locker repo." >&2
    else
        echo "Failed to check out Locker repo." >&2
        exit 1
    fi
fi
cd Locker
npm install
python setupEnv.py
node lockerd.js