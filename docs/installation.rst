################################################################################
 Installation
################################################################################

.. highlight:: bash

.. only:: html

    .. contents::
        :local:

.. admonition:: Alberon Note
    :class: note wy-alert-success

    If you are using Jericho (Alberon's shared development server), Awe is already installed and you can skip to :doc:`config`.


================================================================================
 Quick start
================================================================================

If you already know what you're doing, this is a shorthand version of the instructions below for Debian Wheezy::

    $ curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
    $ sudo apt-get install -y nodejs
    $ sudo gem install bundler
    $ sudo npm install -g awe bower


.. _requirements:

================================================================================
 System requirements
================================================================================

----------------------------------------
 Linux
----------------------------------------

Awe is developed and tested on Linux. It should run on Mac OS X too, but it hasn't been tested. It probably won't work on Windows (at least not 100%) because it uses symlinks.

.. admonition:: Future Plans
    :class: note

    I could add Windows support if there is demand for it, but this would add some complexity (e.g. symlinks to ``bower_components/`` would not be possible so the files would need to be copied instead).


----------------------------------------
 Node.js & npm
----------------------------------------

`Node.js <https://nodejs.org/>`_ v0.12+ and `npm <https://www.npmjs.org/>`_ must be installed. Awe is tested on Node.js 0.10, and may not work on older versions.

To check they're installed, run::

    $ node --version
    $ npm --version


Installing Node.js on Debian
............................

::

    $ curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
    $ sudo apt-get install -y nodejs

See `NodeSource <https://github.com/nodesource/distributions>`_ for more details or other versions.

----------------------------------------
 Ruby & Bundler
----------------------------------------

You must also have `Ruby <https://www.ruby-lang.org/>`_ and `Bundler <http://bundler.io/>`_ installed - they are required to run `Compass <http://compass-style.org/>`_, Sass files to CSS.

Since Awe is installed system-wide, they also need to be installed system-wide - i.e. not using `RVM <https://rvm.io/>`_ or `rbenv <https://github.com/sstephenson/rbenv>`_.

To check they're installed, run::

    $ ruby --version
    $ bundle --version

(Compass itself will be installed by Awe, so it does not need to be installed manually.)


Installing Ruby on Debian
.........................

::

    $ sudo apt-get install ruby ruby-dev
    $ sudo gem install bundler


----------------------------------------
 Bower (optional)
----------------------------------------

You may also install `Bower <http://bower.io/>`_ for managing third-party assets::

    $ sudo npm install -g bower

To check it's installed, run::

    $ bower --version


================================================================================
 Installing
================================================================================

Simply install Awe using npm::

    $ sudo npm install -g awe

This will install the Awe package globally, including the ``awe`` executable, and also download the Node.js and Ruby dependencies.

To check it's installed, run::

    $ awe --version


----------------------------------------
 Installing a specific version
----------------------------------------

To install a specific version, use the ``awe@<version>`` syntax of npm, for example::

    $ sudo npm install -g awe@1.0.0

To see a list of all available versions, see the `list of releases <https://github.com/alberon/awe/releases>`_ or the `list of commits <https://github.com/alberon/awe/commits>`_.


================================================================================
 Upgrading
================================================================================

Because Awe is installed globally, you only need to upgrade it once per machine, not separately for each project. Every effort will be made to ensure backwards compatibility, though you should check :doc:`upgrading` to see if anything important has changed.


----------------------------------------
 Checking for updates
----------------------------------------

::

    $ npm outdated -g awe

If Awe is up to date, only the headings will be displayed::

    Package  Current  Wanted  Latest  Location

If there is a newer version, the currently installed version and latest version number will be displayed::

    Package  Current  Wanted  Latest  Location
    awe        1.0.0   1.1.0   1.1.0  /usr/lib > awe


----------------------------------------
 Upgrading to the latest version
----------------------------------------

::

    $ sudo npm update -g awe


----------------------------------------
 Upgrading to a specific version
----------------------------------------

To upgrade (or downgrade) to a specific version, use ``install`` instead::

    $ sudo npm install -g awe@1.0.0


================================================================================
 Uninstalling
================================================================================

To remove Awe from your machine, simply uninstall it with npm::

    $ sudo npm uninstall -g awe

This will also delete the Node.js and Ruby dependencies that were downloaded automatically during installation (e.g. CoffeeScript, Sass, Compass). It will not remove any project files (configuration, cache files or compiled assets).
