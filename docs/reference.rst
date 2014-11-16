################################################################################
 Quick reference
################################################################################

.. only:: html

    .. contents::
        :local:


================================================================================
 Command-line interface (``awe``)
================================================================================

----------------------------------------
 Global commands
----------------------------------------

These commands can be run from any directory:

.. code-block:: bash

    # Create an awe.yaml file in the current directory
    $ awe init

    # Display help
    $ awe help

    # Display the current version number
    $ awe version


----------------------------------------
 Project commands
----------------------------------------

These commands can only be run from a directory containing an ``awe.yaml`` config file (or any subdirectory):

.. code-block:: bash

    # Build once
    $ awe build
    $ awe b

    # Build then wait for further changes
    $ awe watch
    $ awe w


.. _reference-config:

================================================================================
 Configuration file (``awe.yaml``)
================================================================================

.. code-block:: yaml

    # Awe config - see http://awe.alberon.co.uk/ for documentation

    ASSETS:

        groupname:                          # required (a-z, 0-9 only)
            src:          path/to/src/      # required
            dest:         path/to/build/    # required
            bower:        bower_components/ # optional (default: off)
            autoprefixer: on                # optional (default: off)

        anothergroup:                       # optional
            # ...


================================================================================
 Assets directory structure
================================================================================

::

    SOURCE                     DESTINATION                  NOTES
    ─────────────────────────  ───────────────────────────  ───────────────────────────────────────
    src/                       build/
    │                          │
    │                          ├── _DO_NOT_EDIT.txt         Warning file (automatically generated)
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
    │   ├── 1.css              │
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
    ├── subdirectory/          ├── subdirectory/            Directory structure is preserved
    │   ├── A.css              │   ├── A.css
    │   ├── B.scss             │   ├── B.css
    │   ├── C.js               │   ├── C.js
    │   └── D.coffee           │   └── D.js
    │                          │
    ├── vendor.css.yaml        ├── vendor.css               YAML import file (.css.yaml)
    └── vendor.js.yaml         └── vendor.js                YAML import file (.js.yaml)

.. tip::

    It will also generate source maps -- e.g. ``combined.css.map`` -- but these are not shown for simplicity.


================================================================================
 YAML import files
================================================================================

.. code-block:: yaml

    - _vendor/jquery.js         # Relative path to partial
    - ../vendor/jquery.js       # Relative path to outside directory
    - bower: jquery/jquery.js   # File inside bower_components/
