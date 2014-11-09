##############
 Contributing
##############

.. contents::
   :local:


To submit an improvement to the documentation, simply edit the file using `GitHub <https://github.com/davejamesmiller/awe>`_. This will automatically be turned into a pull request.

If you want to submit a bug fix, the information below may help you to get started. Make your changes in a new branch, based on the ``develop`` branch, then simply open a `pull request <https://github.com/davejamesmiller/awe/pulls>`_ on GitHub.

If you want to submit a new feature, you may want to open an `issue <https://github.com/davejamesmiller/awe/issues>`_ to discuss the idea first, to make sure it will be accepted. (Or you can go ahead and develop it first if you prefer!)


=====================
 Installing from Git
=====================

---------------------------
 Check system requirements
---------------------------

First make sure your system meets the `system requirements <installing#system-requirements>`_.

----------------------
 Download source code
----------------------

Obtain a copy of the Awe source code, if you haven't already. If you are planning to make changes, it is easier to `fork the Awe repository on GitHub <https://github.com/davejamesmiller/awe/fork>`_ first - then use your own username below.

You can install Awe into any location - ``~/awe/`` would be a logical choice.

.. code-block:: bash

    $ cd ~
    $ git clone git@github.com:davejamesmiller/awe.git

----------------------
 Install dependencies
----------------------

.. code-block:: bash

    $ cd awe
    $ npm install

This will:

- Install Node.js dependencies using npm
- Install Ruby dependencies using Bundler
- Compile the source files (from `IcedCoffeeScript <http://maxtaco.github.io/coffee-script/>`_ to JavaScript)
- Run the test suite (`Mocha <http://visionmedia.github.io/mocha/>`_)

At this point it should be possible to run Awe by specifying the path to the executable:

.. code-block:: bash

    $ ~/awe/bin/awe --version

----------------------------------------
 Make it the default version (optional)
----------------------------------------

If you would like to run ``awe`` directly, instead of using the full path, you can use **one** of the following options:

a. For yourself only using ``alias``
....................................

.. code-block:: bash

    $ alias awe="$HOME/awe/bin"

To remove it later (revert to the globally installed version):

.. code-block:: bash

    $ unalias awe

To make this change permanent, add it to your shell config file - for example:

.. code-block:: bash

    $ echo 'alias awe="$HOME/awe/bin"' >> ~/.bashrc

b. For yourself only using ``$PATH``
....................................

Alternatively, you can add it to your system path:

.. code-block:: bash

    $ export PATH="$HOME/awe/bin:$PATH"

This is perhaps a more accurate test of functionality, and may be necessary if you are running Awe from a script.

Again you can make this change permanent by adding it to your shell config script:

.. code-block:: bash

    $ echo 'export PATH="$HOME/awe/bin:$PATH"' >> ~/.bashrc

c. System-wide using ``npm link``
.................................

Or, finally, you can install it system-wide using npm. This has the advantage of allowing you to test the manual page (``man awe``) as well, but it's probably best to avoid this method on a multi-user system as it will replace any other versions that are installed.

.. code-block:: bash

    $ sudo npm uninstall -g awe  # Remove currently installed version, if any
    $ sudo npm link

You may get the following warning messages due to npm security restrictions - they can be ignored as long as you ran ``npm install`` above::

    npm WARN cannot run in wd awe@1.0.0 bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --deployment --without=development
    npm WARN cannot run in wd awe@1.0.0 grunt build test

To remove it later:

.. code-block:: bash

    $ sudo npm uninstall -g awe

------------------------
 Upgrading Awe from Git
------------------------

.. code-block:: bash

    $ cd awe
    $ git pull
    $ npm install

--------------
 Uninstalling
--------------

If you have made it the system-wide default version, remove it first:

.. code-block:: bash

    $ sudo npm uninstall -g awe

Then simply delete the source directory.


=============
 Grunt tasks
=============

The following tasks are used when developing Awe:

.. code-block:: bash

    # Build everything and then watch for further changes
    $ grunt         # 'watch' is the default task
    $ grunt watch

    # Build `lib/` from `lib-src/` (IcedCoffeeScript to JavaScript)
    $ grunt lib

    # Build `man/` from `man-src/` (Markdown to Man pages)
    $ grunt man

    # Build everything
    $ grunt build

    # Run all unit tests
    $ grunt test

    # Run unit tests in `test/<suite>.coffee` only
    $ grunt test <suite>

    # Update the Ruby gems to the latest version
    $ grunt bundle

------------------
 Installing Grunt
------------------

If you don't already have the Grunt CLI installed, you can install it with npm:

.. code-block:: bash

    $ sudo npm install -g grunt-cli


============
 Unit tests
============

Please ensure that every important function and bug fix has corresponding unit tests.

When you run ``grunt watch``, every time you modify a source file (``lib-src/*.iced``) the corresponding unit tests (``tests/*.coffee``) will be run automatically. When you're finished, run ``grunt test`` to run all unit tests.


=======================
 Writing documentation
=======================

-------------------
 Installing Sphinx
-------------------

Install virtualenvwrapper:

.. code-block:: bash

    $ sudo pip install virtualenvwrapper
    $ echo '[ -f /usr/local/bin/virtualenvwrapper_lazy.sh ] && source /usr/local/bin/virtualenvwrapper_lazy.sh' >> ~/.bashrc
    $ source /usr/local/bin/virtualenvwrapper_lazy.sh

Create & switch to that environment:

.. code-block:: bash

    $ mkvirtualenv awe
    $ pip install -r requirements.txt

Then in future sessions switch to that environment before running ``grunt``:

.. code-block:: bash

    $ workon awe
    $ grunt

------------------
 Sphinx reference
------------------

- `reStructuredText quick reference <http://docutils.sourceforge.net/docs/user/rst/quickref.html>`_
- `Paragraph-level markup <http://sphinx-doc.org/markup/para.html>`_ (``note::``, ``warning::``, etc.)
- `Code examples markups <http://sphinx-doc.org/markup/code.html>`_ (``code-block::``)
- `Inline markup <http://sphinx-doc.org/markup/inline.html>`_ (``:ref:``, ``:doc:``, etc.)
- `TOC tree <http://sphinx-doc.org/markup/toctree.html>`_ (``:toctree:``)
- `Wyrm CSS classes <http://wyrmsass.org/section-4.html>`_

========================
 Writing Markdown files
========================

The documentation is written in `GitHub Flavored Markdown <https://help.github.com/articles/github-flavored-markdown>`_, designed to be viewed directly in the GitHub interface. This makes it easy to find the documentation for the currently installed version, or any other version, simply by switching branches/tags.

-------------
 Conventions
-------------

Please respect the following conventions when editing the Awe documentation:

- Write paragraphs on a single line, not with new lines to limit the line length - this makes it easier to edit text later
- Use ``- hyphens`` for lists instead of ``* asterisks`` - they're easier to type
- Use ``# hash marks`` for headings instead of underlining them - ditto

-------------------------------
 Viewing documentation locally
-------------------------------

When editing a lot of documentation, it's helpful to be able to preview it before you commit and upload your changes. For this I strongly recommend using `Grip - GitHub Readme Instant Preview <https://github.com/joeyespo/grip>`_.

To install Grip run:

.. code-block:: bash

    $ sudo pip install grip --upgrade

By default Grip will only be accessible on ``localhost``, not over the network. If you're using a separate development server or virtual machine, you will need to configure it to allow access on all network interfaces:

.. code-block:: bash

    $ mkdir ~/.grip
    $ echo "HOST = '0.0.0.0'" >> ~/.grip/settings.py

If you find yourself hitting the rate limit (60 requests per hour), you will need to `generate a personal access token <https://github.com/settings/tokens/new?scopes=>`_ and enable authentication:

.. code-block:: bash

    $ echo "USERNAME = '<username>'" >> ~/.grip/settings.py
    $ echo "PASSWORD = '<token>'" >> ~/.grip/settings.py

**Tip:** For security, don't enter your password in ``settings.py`` - always use an access token. (Also, you should enable `Two-Factor Authentication <https://help.github.com/articles/about-two-factor-authentication>`_ on your account.)

For more details, please see the `Grip readme <https://github.com/joeyespo/grip>`_.

To start the Grip server, simply run it from the Awe source directory:

.. code-block:: bash

    $ cd /path/to/awe
    $ grip

Then open ``http://<hostname>:5000/`` in your web browser.

To stop the Grip server, type ``Ctrl-C``.

Troubleshooting: Address already in use
.......................................

If you get this error message::

    Traceback (most recent call last):
      ...
    socket.error: [Errno 98] Address already in use

This means port ``5000`` is already in use - either by another instance of Grip or by another process. You can specify a different port number instead:

.. code-block:: bash

    $ grip 5001

Then open ``http://<hostname>:5001/`` in your web browser instead.


=========================
 Releasing a new version
=========================

---------
 Prepare
---------

- Run ``git pull`` to ensure all changes are merged
- Test with ``grunt test``
- Check the documentation is up-to-date
- Update the changelog

---------
 Release
---------

- Run ``npm version X.Y.Z`` to update ``package.json``
- Run ``git push && git push --tags`` to upload the code and tag to GitHub
- Run ``npm publish`` to upload to npm

----------
 Finalise
----------

- Run ``sudo npm update -g awe`` to upgrade Awe on your own machine(s)
