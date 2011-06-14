# LockerBox #

LockerBox is a small script to get you up and running with
[Locker](http://lockerproject.org/) as quickly and easily as possible,
without having to spend a lot of time or effort getting all the
dependencies set up.

At the moment, this is more intended for developers who want to
evaluate Locker than end users. However, this could be a first step
toward a system for building end-user packages of Locker.

## Dependencies ##

There are only three or four things that are needed in order to get
Locker up and running using LockerBox:

 - Python 2.6+

 - Git

 - A C++ build environment (Make, a C++ compiler, and libssl)

 - Node.js 0.4.8 (optional)

If you don't already have Node.js 0.4.8+ installed, it will be built
for you, and installed in the lockerbox directory. How long this takes
will depend on your machine.

Any other dependencies will be automatically downloaded and installed
into lockerbox/local, including:

 - [Node.js](http://nodejs.org)

 - [npm](http://npmjs.org)

 - [virtualenv](http://www.virtualenv.org/)

 - [MongoDB](http://mongodb.org)

 - and various Python and Node.js dependencies

Of course, if you already have recent enough versions of Node.js, npm,
virtualenv, and MongoDB installed, they won't be re-installed
locally. Instead, the already-installed versions will be used.

## Usage ##

Just run:

    ./lockerbox.sh

Or if you don't want to download first:

    curl https://raw.github.com/pib/lockerbox/master/lockerbox.sh | sh

The second option will create a directory called "lockerbox" and put
everything there. The first will run in the current directory (which
makes sense if you've just checked out the repo).

Either way, as soon as everything needed is downloaded and started,
Locker should be up and running, and you can visit
[localhost:8042](http://localhost:8042/) to see your running copy of
Locker.

The next time you run lockerbox.sh, it won't need to install anything,
it will just check that it's all there, and then launch Locker.

## And then? ##

At this point, you should have a copy of Locker in
lockerbox/Locker. Now start hacking away!

If something in your environment gets messed up somehow, you can
always blow away lockerbox/local and/or lockerbox/Locker and they will
be auto-filled with dependencies again the next time lockerbox.sh is
run.
