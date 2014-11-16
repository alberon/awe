################################################################################
 Introduction
################################################################################

.. Note: This intro is also used in ../README.md and a short version for the description on GitHub.

Awe (Alberon Web Engine) simplifies the building and maintenance of websites / web apps, by handling the compilation of **assets** -- it makes it easy to compile CoffeeScript & Sass files, autoprefix CSS files and combine source files together, with full source map support for easier debugging.

In the future it will also handle **deployment** to remote live/staging servers, and related functionality such as **configuration management**.


================================================================================
 Features
================================================================================

----------------------------------------
 Assets
----------------------------------------

- Compile `CoffeeScript <http://coffeescript.org/>`_ (``.coffee``) files to JavaScript
- Compile `Sass <http://sass-lang.com/>`_/`Compass <http://compass-style.org/>`_ (``.scss``) files to CSS
- `Autoprefix <https://github.com/ai/autoprefixer>`_ CSS rules for easier cross-browser compatibility
- Combine multiple JavaScript/CSS source files into a single file
- Rewrite relative URLs in CSS files that are combined (e.g. packages installed with `Bower <http://bower.io/>`_)
- Generate `source maps <http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/>`_ to aid debugging
- Watch for changes to source files and rebuild automatically


----------------------------------------
 Miscellaneous
----------------------------------------

- Simple YAML configuration (no need to set up lots of separate plugins!)
- Detailed documentation
- Unit tests to ensure backwards compatibility


.. admonition:: Future Plans
    :class: note

    I hope to add the some of following features in the future, depending on demand for them:

    **Assets**

    - Only rebuild modified files, to speed up builds [#]_
    - `Automatically reload <http://livereload.com/>`_ your web browser when assets are rebuilt
    - `Growl <http://www.growlforwindows.com/gfw/>`_ notifications when there are build errors
    - Minify `JavaScript <https://github.com/mishoo/UglifyJS>`_ & `CSS <https://github.com/jakubpawlowicz/clean-css>`_ files
    - `Optimise images <https://github.com/imagemin/imagemin>`_
    - `Pre-compress assets <http://stackoverflow.com/questions/9076752/how-to-force-apache-to-use-manually-pre-compressed-gz-file-of-css-and-js-files>`_ to reduce file size while minimising CPU usage
    - Cache-busting filenames, allowing long browser cache times
    - Inline Angular HTML templates
    - SVG icons (e.g. `Grunticon <https://github.com/filamentgroup/grunticon>`_)
    - `Browserify <http://browserify.org/>`_ support

    **Deployment**

    - Deploy to remote (live/staging) servers via SSH (either in-place or using releases & symlinks like Capistrano)
    - Deploy assets to a CDN
    - Database migrations
    - Install dependencies (npm, composer, bundler) as needed
    - Download databases & files from remote sites for testing, replacing URLs and anonymising email addresses
    - Upload databases & files to remote sites for initial deployment

    **Configuration management**

    - Automatically switch config settings for different servers, including development sites
    - Store passwords outside the Git repository
    - Manage crontab on each server
    - Manage file permissions
    - MySQL integration (``awe mysql``, ``awe mysqldump`` -- using connection details from config)
    - SSH integration (``awe ssh`` -- using remote server details from config)

    **Miscellaneous**

    - Tab completion in shell
    - Backup & restore databases & files
    - Use the cPanel API to create & delete staging sites automatically
    - Hooks to add custom functionality
    - Custom commands
    - Generate documentation (`Sphinx <http://sphinx-doc.org/>`_)
    - Generate API documentation (`phpDocumentor <http://www.phpdoc.org/>`_)
    - Unit testing framework integration (`PHPUnit <https://phpunit.de/>`_, `Mocha <http://mochajs.org/>`_)
    - Linters (`CSS <http://csslint.net/>`__, `JavaScript <http://www.jshint.com/docs/>`__, `CoffeeScript <http://www.coffeelint.org/>`__, `Sass <https://github.com/causes/scss-lint>`__, `PHP <http://www.icosaedro.it/phplint/>`_, `Python <https://pypi.python.org/pypi/pep8>`_)
    - `Vagrant <https://www.vagrantup.com/>`_ integration
    - Search for ``TODO`` and similar comments in source code
    - Interactive menu / GUI

.. [#] This is harder than it sounds -- Compass is the slowest part of the build, and it can have multiple input and output files (e.g. partials, sprites) making it difficult to detect which files need to be rebuilt.


================================================================================
 About the author
================================================================================

`Dave James Miller <https://davejamesmiller.com/>`_ is Senior Developer at `Alberon <http://www.alberon.co.uk/>`_. He builds websites with WordPress, applications with Laravel, manages the Linux web servers and leads the PHP development team.
