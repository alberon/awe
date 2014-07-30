# Awe Installation

## Dependencies

### Linux

Awe is developed and tested on Linux (specifically on Debian Wheezy). It will most likely run on OS X too, though it hasn't been tested.

It will not work on Windows because some features require symlinks. (It may be possible to get it working under Cygwin, but only if someone wants to spend the time testing and documenting it.)

### Node.js

[Node.js](http://nodejs.org/) and [npm](https://www.npmjs.org/) must be installed. Awe is tested on Node.js 0.10.26, and may not work on older versions.

#### Installing Node.js on Debian

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

To check it's installed, run:

```bash
$ npm --version
```

### Ruby

You must also have [Ruby](https://www.ruby-lang.org/) and [Bundler](http://bundler.io/) installed, because [Compass](http://compass-style.org/) is used to compile Sass to CSS. Since Awe is designed to be installed system-wide, they also need to be installed system-wide - i.e. not using [RVM](https://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv).

### Bower (optional but recommended)

You may also install [Bower](http://bower.io/) for managing third-party assets:

```bash
sudo npm install -g bower
```

To check it's installed, run:

```bash
$ bower --version
```

#### Installing Ruby on Debian

```bash
$ sudo apt-get install ruby ruby-dev
$ sudo gem install bundler
```

To check it's installed, run:

```bash
$ bundle --version
```

**Note:** Compass itself will be installed automatically when you install Awe, so it does not need to be installed manually. (It is installed using Bundler, so it won't conflict with any existing version that may be installed, nor will it install the `compass` executable.)

## Installing Awe

Make sure you have installed the dependencies listed above, then run:

```bash
$ sudo npm install -g awe
```

This will install the Awe package globally, including the `awe` executable, and also download the Node.js and Ruby dependencies.

To install a specific version, use the `awe@<version>` syntax, for example:

```bash
$ sudo npm install -g awe@1.0.0
```

(Or to install a development version, see [Installing from Git](installing-from-git.md).)

To check it's installed, run:

```bash
$ awe --version
```

## Upgrading Awe

```bash
$ sudo npm update -g awe
```

To upgrade (or downgrade) to a specific version, use `install` instead:

```bash
$ sudo npm install -g awe@1.0.0
```

## Uninstalling Awe

```bash
$ sudo npm uninstall -g awe
```
