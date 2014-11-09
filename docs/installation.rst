##############
 Installation
##############

.. only:: html

    .. contents::
       :local:

.. note::
   :class: wy-alert-success

   If you are using Jericho (Alberon's shared development server) you can skip to :doc:`setup`.

.. _requirements:

=====================
 System requirements
=====================

-------
 Linux
-------

Awe is developed and tested on Linux. It should run on Mac OS X too, but it hasn't been tested. It won't work on Windows because it uses symlinks.

---------------
 Node.js & npm
---------------

`Node.js <https://nodejs.org/>`_ and `npm <https://www.npmjs.org/>`_ must be installed. Awe is tested on Node.js 0.10, and may not work on older versions.

To check they're installed, run:

.. code-block:: bash

    $ node --version
    $ npm --version

Installing Node.js on Debian
............................

On Debian Wheezy, Node.js is only available in `Backports <http://backports.debian.org/>`_, but you will need to add that as a source:

.. code-block:: bash

    $ sudo vim /etc/apt/sources.list

Add this line::

    deb     http://ftp.uk.debian.org/debian/ wheezy-backports main contrib non-free

Then run the following to install it:

.. code-block:: bash

    $ sudo apt-get update
    $ sudo apt-get install curl nodejs nodejs-legacy
    $ curl https://www.npmjs.org/install.sh | sudo sh

----------------
 Ruby & Bundler
----------------

You must also have `Ruby <https://www.ruby-lang.org/>`_ and `Bundler <http://bundler.io/>`_ installed - they are required to run `Compass <http://compass-style.org/>`_, Sass files to CSS.

Since Awe is installed system-wide, they also need to be installed system-wide - i.e. not using `RVM <https://rvm.io/>`_ or `rbenv <https://github.com/sstephenson/rbenv>`_.

To check they're installed, run:

.. code-block:: bash

    $ ruby --version
    $ bundle --version

(Compass itself will be installed by Awe, so it does not need to be installed manually.)

Installing Ruby on Debian
.........................

.. code-block:: bash

    $ sudo apt-get install ruby ruby-dev
    $ sudo gem install bundler

------------------
 Bower (optional)
------------------

You may also install `Bower <http://bower.io/>`_ for managing third-party assets:

.. code-block:: bash

    sudo npm install -g bower

To check it's installed, run:

.. code-block:: bash

    $ bower --version


============
 Installing
============

Simply install Awe using npm:

.. code-block:: bash

    $ sudo npm install -g awe

This will install the Awe package globally, including the ``awe`` executable, and also download the Node.js and Ruby dependencies.

To check it's installed, run:

.. code-block:: bash

    $ awe --version

-------------------------------
 Installing a specific version
-------------------------------

To install a specific version, use the ``awe@<version>`` syntax of npm, for example:

.. code-block:: bash

    $ sudo npm install -g awe@1.0.0

To see a list of all available versions, see the :doc:`changelog`.


===========
 Upgrading
===========

Because Awe is installed globally, you only need to upgrade it once per machine, not separately for each project. Every effort will be made to ensure backwards compatibility, though you should check the :doc:`changelog` to see what has changed.

----------------------
 Checking for updates
----------------------

.. code-block:: bash

    $ npm outdated -g awe

If Awe is up to date, only the headings will be displayed::

    Package  Current  Wanted  Latest  Location

If there is a newer version, the currently installed version and latest version number will be displayed::

    Package  Current  Wanted  Latest  Location
    awe        1.0.0   1.1.0   1.1.0  /usr/lib > awe

---------------------------------
 Upgrading to the latest version
---------------------------------

.. code-block:: bash

    $ sudo npm update -g awe

---------------------------------
 Upgrading to a specific version
---------------------------------

To upgrade (or downgrade) to a specific version, use ``install`` instead:

.. code-block:: bash

    $ sudo npm install -g awe@1.0.0


==============
 Uninstalling
==============

To remove Awe from your machine, simply uninstall it with npm:

.. code-block:: bash

    $ sudo npm uninstall -g awe

This will also delete the Node.js and Ruby dependencies that were downloaded automatically during installation (e.g. CoffeeScript, Sass, Compass). It will not remove any project files (configuration, cache files or compiled assets).
