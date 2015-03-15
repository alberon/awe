################################################################################
 Introduction
################################################################################

.. Note: This intro is also used in ../README.md and a short version for the description on GitHub.

Awe is a tool used at `Alberon <http://www.alberon.co.uk>`_ to simplify the building and maintenance of websites / web apps, by handling the compilation of assets. It makes it easy to compile CoffeeScript & Sass files, autoprefix CSS files and combine source files together, with full source map support for easier debugging.

(In the future it will also handle deployment to remote live/staging servers, and related functionality such as configuration management.)

While it is not designed to be used by third parties, it is open source and you're welcome to use it if you want to!


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
 Deployment
----------------------------------------

*Coming soon!*
