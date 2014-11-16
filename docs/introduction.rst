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
- Unit tests to ensure backwards-compatibility


.. admonition:: Future Plans
    :class: note

    I plan to add the following features in the future:

    - Minify JavaScript & CSS files
    - Optimise images
    - `Automatically reload <http://livereload.com/>`_ your web browser when assets are rebuilt
    - `Growl <http://www.growlforwindows.com/gfw/>`_ notifications when there are build errors
    - Deploy to remote (live/staging) servers
    - Automatically switch config settings for different servers, inclusing development sites
    - Download/upload data (databases and files) from/to remote sites (for testing or initial deployment)


================================================================================
 About the author
================================================================================

`Dave James Miller <https://davejamesmiller.com/>`_ is Senior Developer at `Alberon <http://www.alberon.co.uk/>`_. He builds websites with WordPress, applications with Laravel, manages the Linux web servers and leads the PHP development team.
