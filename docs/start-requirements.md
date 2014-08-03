# System requirements for Awe

## Linux

Awe is developed and tested on Linux (specifically on Debian Wheezy, v7.4). It will most likely run on OS X too, though it hasn't been tested.

It will not work on Windows because some features use symlinks. It may be possible to get it working under Cygwin, but this also hasn't been tested. (This may be reconsidered if there is demand for it.)

## Node.js & npm

[Node.js](http://nodejs.org/) and [npm](https://www.npmjs.org/) must be installed. Awe is tested on Node.js 0.10.26, and may not work on older versions.

To check it's installed, run:

```bash
$ npm --version
```

### Installing on Debian

On Debian Wheezy, Node.js is only available in [Backports](http://backports.debian.org/), but you will need to add that as a source:

```bash
$ sudo vim /etc/apt/sources.list
```

Add this line:

```
deb     http://ftp.uk.debian.org/debian/ wheezy-backports main contrib non-free
```

Then run the following to install it:

```bash
$ sudo apt-get update
$ sudo apt-get install curl nodejs nodejs-legacy
$ curl https://www.npmjs.org/install.sh | sudo sh
```

## Ruby & Bundler

You must also have [Ruby](https://www.ruby-lang.org/) and [Bundler](http://bundler.io/) installed, because [Compass](http://compass-style.org/) is used to compile Sass to CSS. Since Awe is designed to be installed system-wide, they also need to be installed system-wide - i.e. not using [RVM](https://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv).

To check it's installed, run:

```bash
$ bundle --version
```

**Note:** Compass itself will be installed automatically when you install Awe, so it does not need to be installed manually. (It is installed using Bundler, so it won't conflict with any existing version that may be installed, nor will it install the `compass` executable.)

### Installing on Debian

```bash
$ sudo apt-get install ruby ruby-dev
$ sudo gem install bundler
```

## Bower (optional)

You may also install [Bower](http://bower.io/) for managing third-party assets:

```bash
sudo npm install -g bower
```

To check it's installed, run:

```bash
$ bower --version
```

This isn't required, however, because you can choose to install them manually.
