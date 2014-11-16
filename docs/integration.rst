################################################################################
 Integration with other software
################################################################################

================================================================================
 WordPress
================================================================================

The recommended directory structure for WordPress is::

    repo/
    ├── bower_components/               # Bower packages
    ├── www/
    │   └── wp-content/
    │       └── themes/
    │           └── mytheme/
    │               ├── build/          # Build files
    │               ├── src/            # Source files
    │               │   ├── main.css/
    │               │   └── main.js/
    │               └── style.css       # Theme config (no CSS code!)
    └── awe.yaml                        # Awe config

With the following configuration:

.. code-block:: yaml

    ASSETS:

        default:
            src:          www/wp-content/themes/mytheme/src/
            dest:         www/wp-content/themes/mytheme/build/

``style.css`` should only contain the `file header <http://codex.wordpress.org/File_Header>`_ that WordPress requires -- for example:

.. code-block:: css

    /*
    Theme Name: My Theme
    ...
    */

Then ``main.css`` should be used in the HTML code (instead of ``bloginfo('stylesheet_url')``):

.. code-block:: html+php

    <link rel="stylesheet" href="<?= get_template_directory_uri() ?>/build/main.css">


================================================================================
 Laravel 5
================================================================================

The recommended directory structure for `Laravel <http://laravel.com/>`_ 5 is::

    repo/
    ├── app/
    ├── bower_components/   # Bower packages
    ├── public/
    │   └── assets/         # Build files
    ├── resources/
    │   └── assets/         # Source files
    │       ├── main.css/
    │       └── main.js/
    └── awe.yaml            # Awe config

With the following configuration:

.. code-block:: yaml

    ASSETS:

        default:
            src:          resources/assets/
            dest:         public/assets/


================================================================================
 Laravel 4
================================================================================

The recommended directory structure for `Laravel <http://laravel.com/>`_ 4 is::

    repo/
    ├── app/
    │   └── assets/         # Source files
    │       ├── main.css/
    │       └── main.js/
    ├── bower_components/   # Bower packages
    ├── public/
    │   └── assets/         # Build files
    └── awe.yaml            # Awe config

With the following configuration:

.. code-block:: yaml

    ASSETS:

        default:
            src:          app/assets/
            dest:         public/assets/
