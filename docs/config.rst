################################################################################
 Configuration
################################################################################

.. only:: html

    .. contents::
        :local:


================================================================================
 awe.yaml
================================================================================

Each project requires a single config file, ``awe.yaml``, in the root directory. A config file can be created in the current directory by running ``awe init``:

.. code-block:: bash

    $ cd /path/to/repo
    $ awe init

Then simply open ``awe.yaml`` in your preferred text editor to customise it as needed.

Alternatively you can create a config file by hand, or copy one from another project.


================================================================================
 About the YAML format
================================================================================

The file is in YAML (v1.2) format. This is similar in purpose to JSON, but easier to read and write. Here is an example config file in YAML:

.. code-block:: yaml

    ASSETS:

        # This is a comment
        default:
            src:        www/wp-content/themes/mytheme/src/
            dest:       www/wp-content/themes/mytheme/build/
            sourcemaps: on

Note how indentation is used to determine the structure, similar to Python and CoffeeScript, and strings do not need to be quoted. It also supports comments, unlike JSON. The equivalent JSON file would be:

.. code-block:: json

    {
        "ASSETS": {

            "_comment": "This is a comment (http://stackoverflow.com/a/244858/167815)",
            "theme": {
                "src":        "www/wp-content/themes/mytheme/src/",
                "dest":       "www/wp-content/themes/mytheme/build/",
                "sourcemaps": true
            }

        }
    }

You shouldn't need to know any more than this to configure Awe, but if you would like to learn more about YAML, please see `Wikipedia <http://en.wikipedia.org/wiki/YAML>`_ or the `official YAML website <http://www.yaml.org/>`_.


================================================================================
 Config sections
================================================================================

The config file is designed to be split into sections. Each top-level section is written in UPPERCASE to make it stand out.

Currently the only section supported is ``ASSETS``, but in the future the config file may look like this:

.. code-block:: yaml

    ASSETS:

        # Asset groups config

    CONFIG:

        # Custom settings

    CRON:

        # Cron jobs config

    DEPLOY:

        # Deployment config

    ENVIRONMENTS:

        # Configure environments (dev, staging, live)

    MYSQL:

        # MySQL config

    PERMISSIONS:

        # File permissions config

    SETUP:

        # Setup command config (e.g. npm, composer, bundler)

    VERSIONS:

        # Require specific versions of Awe, CoffeeScript, etc.
