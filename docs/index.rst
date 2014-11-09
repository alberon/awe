#################################
 Awe --- Alberon Web Environment
#################################

.. toctree::
   :hidden:

   Overview <self>
   installation
   setup
   assets
   reference
   changelog
   contributing
   license


Awe is a command-line build tool for website assets - it makes it easy to compile CoffeeScript & Sass files, autoprefix CSS files and combine source files together - with full source map support for easier debugging.

It is designed for web/software development agencies and freelancers managing many different websites, so:

- It relies on convention rather than configuration, to make it easy to use and ensure consistency between sites
- It is installed system-wide, not per-project, to avoid the maintenance overhead of installing and upgrading it for each site separately

Unlike `Grunt <http://gruntjs.com/>`_ and `Gulp <http://gulpjs.com/>`_, Awe is not designed to be a general purpose task runner or build tool - so it won't suit everyone, but it should be much easier to configure.


==========
 Features
==========

--------
 Assets
--------

- Compile `CoffeeScript <http://coffeescript.org/>`_ (``.coffee``) files to JavaScript
- Compile `Sass <http://sass-lang.com/>`_/`Compass <http://compass-style.org/>`_ (``.scss``) files to CSS
- `Autoprefix <https://github.com/ai/autoprefixer>`_ CSS rules for easier cross-browser compatibility
- Combine multiple JavaScript/CSS source files into a single file
- Rewrite relative URLs in CSS files that are combined (e.g. packages installed with `Bower <http://bower.io/>`_)
- Generate `source maps <http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/>`_ to aid debugging
- Watch for changes to source files and rebuild automatically

---------------
 Miscellaneous
---------------

- Simple YAML configuration (no need to set up lots of separate plugins!)
- Detailed documentation
- Unit tests to ensure backwards-compatibility

-------------
 Coming soon
-------------

- Minify JavaScript & CSS files
- Optimise images
- `Automatically reload <http://livereload.com/>`_ your web browser when assets are rebuilt
- `Growl notifications <http://www.growlforwindows.com/gfw/>`_ when there are build errors
- Deploy to remote (live/staging) servers
- Configuration management
