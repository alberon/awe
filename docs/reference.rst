#################
 Quick reference
#################

.. only:: html

    .. contents::
       :local:


==================================
 Command-line interface (``awe``)
==================================

-----------------
 Global commands
-----------------

These commands can be run from any directory:

.. code-block:: bash

    # Create an awe.yaml file in the current directory
    $ awe init

    # Display help
    $ awe help

    # Display the current version number
    $ awe version

------------------
 Project commands
------------------

These commands can only be run from a directory containing an ``awe.yaml`` config file (or any subdirectory):

.. code-block:: bash

    # Build once
    $ awe build

    # Build then wait for further changes
    $ awe watch
    $ awe          # 'watch' is the default command


===================================
 Configuration file (``awe.yaml``)
===================================

.. code-block:: yaml

    ASSETS:

        groupname:                          # required (a-z, 0-9 only)

            src:          path/to/src/      # required
            dest:         path/to/build/    # required
            bower:        bower_components/ # optional (default: false)
            autoprefixer: true              # optional (default: false)
            sourcemaps:   true              # optional (default: false)
            warning file: true              # optional (default: false)

        anothergroup:                       # optional

            #...


============================
 Assets directory structure
============================

::

    SOURCE                     DESTINATION                  NOTES
    ─────────────────────────  ───────────────────────────  ───────────────────────────────────────
    src/                       build/
    │                          │
    │                          ├── _bower/                  Symlink to bower_components/ directory
    │                          │
    │                          ├── _generated/              Compass─generated files (e.g. sprites)
    │                          │   └── nav-s71af1c74.png
    │                          │
    ├── _partials/             │                            Ignored (starts with _)
    │   └── reset.scss         │
    │                          │
    ├── _sprites/              │                            Compass sprite source images
    │   └── nav/               │
    │       ├── edit.png       │
    │       └── save.png       │
    │                          │
    ├── _vars.scss             │                            Ignored (starts with _)
    │                          │
    ├── combined.css/          ├── combined.css             Combined (ends with .css)
    │   ├── 1.css              │                            Relative URLs are rewritten
    │   ├── 2.scss             │
    │   └── 3-subdirectory/    │
    │       ├── A.css          │
    │       └── B.scss         │
    │                          │
    ├── combined.js/           ├── combined.js              Combined (ends with .js)
    │   ├── 1.js               │
    │   ├── 2.coffee           │
    │   └── 3-subdirectory/    │
    │       ├── A.js           │
    │       └── B.coffee       │
    │                          │
    ├── img/                   ├── img/                     Images are copied unaltered
    │   └── logo.png           │   └── logo.png
    │                          │
    ├── sample1.css            ├── sample1.css              CSS file is copied
    ├── sample2.scss           ├── sample2.css              Sass file is compiled
    ├── sample3.js             ├── sample3.js               JavaScript file is copied
    ├── sample4.coffee         ├── sample4.js               CoffeeScript file is compiled
    │                          │
    └── subdirectory/          └── subdirectory/            Directory structure is preserved
        ├── A.css                  ├── A.css
        ├── B.scss                 ├── B.css
        ├── C.js                   ├── C.js
        └── D.coffee               └── D.js
