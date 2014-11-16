################################################################################
 Design decisions
################################################################################

.. only:: html

    .. contents::
        :local:


================================================================================
 Introduction
================================================================================

A lot of time and effort has gone into making Awe, including a lot of back-and-forth about the best way to build it. Here I document some of the design decisions, both as a reminder for myself and to explain the thinking behind it to others.


================================================================================
 Specific- not general-purpose
================================================================================

Awe was created to make it easier for the team at `Alberon <http://www.alberon.co.uk>`_, a web/software development agency, to manage many different websites and web apps.

Unlike `Grunt <http://gruntjs.com/>`_, `Gulp <http://gulpjs.com/>`_ and others, Awe is not designed to be a general-purpose task runner or build tool, but to perform specific tasks well.


================================================================================
 System-wide installation
================================================================================

Before building Awe I tried using `Grunt <http://gruntjs.com/>`_. This required me to install Grunt and all the plugins I was using in each project, upgrade each project separately when new versions were released, and keep the Gruntfiles in sync so every project had the latest features & fixes as I added them. This was tedious enough with 3 projects -- if it were expanded to all 25+ ongoing projects it would be a nightmare. So Awe is designed to be installed (and upgraded) only once, system-wide.

.. admonition:: Future Plans
    :class: note

    CoffeeScript, Compass, etc. are also installed system-wide, so every project must use the same version. In the future this could be changed to allow specific versions to be required for each project, and Awe would install/upgrade them for each project automatically (in the `.awe/` directory).


================================================================================
 Unit tests
================================================================================

Because Awe is installed system-wide, backwards-compatibility is especially important. So we have plenty of unit tests to ensure nothing breaks.

.. note::

    "Backwards-compatible" doesn't mean completely identical build output -- for example, adding source maps meant adding extra comments to the build files, but they are still backwards-compatible.


================================================================================
 Conservative defaults
================================================================================

Forwards-compatibility is also important for the same reason, so the default settings are quite conservative -- features must be explicitly enabled in the config file, even if they are strongly recommended (e.g. Autoprefixer).


================================================================================
 Minimal configuration
================================================================================

To ensure consistency between sites, only a minimum amount of configuration is allowed. It is limited to:

- Choosing the functionality to use (see above), and
- Allowing for necessary differences between projects (e.g. assets are different directories depending on the framework/CMS used)

In particular, config options should not be added to avoid `making a decision <https://gettingreal.37signals.com/ch06_Avoid_Preferences.php>`_ about the best solution.


================================================================================
 YAML configuration
================================================================================

Many systems allow configuration files to be written in code (e.g. `Gruntfile.js`). While this allows more advanced customisation, I wanted to ensure consistency between sites and keep the configuration simple, which means limiting the options available.

If any extra functionality is required, it should be added to Awe itself, not added through custom project-specific code. This ensures it can be reused in other projects.

.. admonition:: Future Plans
    :class: note

    I would like to add hooks that can be called at certain points (on build, on deploy, etc.) when custom functionality is truely needed. These would most likely be external scripts (which can be written in any language) rather than Node.js functions.


================================================================================
 Automatic mapping of asset files
================================================================================

There are no configuration options for *how* assets are built -- the idea is anyone should be able to look at the source files and work out what the resulting build files will look like.

This is especially important when working with frontend (HTML/CSS) developers who are not programmers, work on a lot of different projects and just want it to work.


================================================================================
 YAML import files
================================================================================

In an early alpha version of Awe, I used symlinks and :ref:`combined directories <combined-directories>` to merge vendor files with custom files. However, when viewing the directory over the network using Samba it was impossible to see which files were symlinks, therefore impossible to tell which files were custom and which were external (e.g. Bower packages). So symlink support was removed in favour of :ref:`YAML import files <yaml-import>`.


================================================================================
 No shorthand syntax in import files
================================================================================

In the :ref:`YAML import files <yaml-import>` you must always use a list, even if there is only one entry:

.. code-block:: yaml

    - ../vendor/jquery.js

You cannot shorten it to:

.. code-block:: yaml

    ../vendor/jquery.js

This is to avoid confusing the user when they try to add a second entry to the file.


================================================================================
 Limited file type support
================================================================================

Awe doesn't support the shorthand Sass syntax (`.sass` files), Less or several other languages purely because we (Alberon) don't currently use them. If we do decide to use them, we can add support for them in the future.

.. admonition:: Future Plans
    :class: note

    I would consider switching to a plugin-based architecture, more like Grunt, as long as Awe installed and upgraded them automatically in response to config options -- i.e. it would not require the user to run ``npm install`` manually.


================================================================================
 Open source
================================================================================

Although Awe has a limited target audience, it is open source to allow other people to use it -- particularly if a third-party takes over maintenance of a site/app we built.

It also allows us to use `GitHub <https://github.com/alberon/awe>`_, `npm <https://www.npmjs.org/package/awe>`_ and `Read the Docs <https://readthedocs.org/projects/awe/>`_.

And if anyone else wants to use it or improve it, that's fine with me too. (Please do `share your changes <https://github.com/alberon/awe/pulls>`_!)


================================================================================
 Flag deprecated features
================================================================================

If any features are deprecated in the future, Awe should warn the user whenever they are used *and* suggest an alternative. There should be no way to disable these warnings. This will ensure that projects are upgraded, so they do not break if that feature is eventually removed.


================================================================================
 Runs over SSH...
================================================================================

----------------------------------------
 ... not locally on Windows
----------------------------------------

Most of us at Alberon develop on Windows but use a Linux development server, editing files over a Samba network drive. This means a local GUI application would not be able to watch for file changes efficiently (e.g. see `Prepros <https://github.com/subash/Prepros/issues/398#issuecomment-60480027>`_), and it would run slower -- so I designed it to run over SSH. (Of course if anyone wants to use it on a Linux desktop, they can run it locally in a terminal window.)


----------------------------------------
 ... not through a web server
----------------------------------------

Another option was to have it run automatically through the web server, rebuilding the files whenever they were requested -- similar to Rails' `asset pipeline <http://guides.rubyonrails.org/asset_pipeline.html>`_. This would have the advantage that it wouldn't be necessary to run Awe over SSH (which easy to forget if you're not used to it). However:

- It's more difficult to display errors this way
- There's not always a 1-to-1 mapping of source to build files, making efficient compilation difficult
- It's slower to detect changed files, as they must be searched for each file loaded
- It adds a precompile step when deploying files
- It would tie us to a particular development language
- It would require more setup for each site


----------------------------------------
 ... not in a browser (web app)
----------------------------------------

Another option would be to build an application frontend that runs in the browser and communicates with a server process using WebSockets. This would be a more friendly interface for less technical frontend developers, but require significant extra work to implement.

*None of these are three options are impossible, but the industry is moving towards command-line build tools so that seemed like the best solution.*


================================================================================
 Both asset building *and* deployment
================================================================================

.. admonition:: Future Plans
    :class: note

    Deployment is not yet available, but is planned for a future release.

I considered splitting asset building and deployment into two separate applications, but:

#. Combining them will make it easier to minify assets before deployment
#. Awe is not meant to be a general-purpose build tool that many people use, so the benefits would be limited
#. It's easier for me to maintain a single application than several smaller ones
