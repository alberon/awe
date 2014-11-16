################################################################################
 Configuration
################################################################################

.. only:: html

    .. contents::
        :local:


================================================================================
 Creating awe.yaml
================================================================================

Each project requires a single config file, ``awe.yaml``, in the root directory. A config file can be created in the current directory by running ``awe init``:

.. code-block:: bash

    $ cd /path/to/repo
    $ awe init

Then simply open ``awe.yaml`` in your preferred text editor to customise it as needed.

.. tip::

    If you prefer you can create a config file by hand, or copy one from another project -- but I recommend using ``awe init`` to ensure you're starting with the latest recommended settings.


================================================================================
 About the YAML format
================================================================================

The file is in `YAML <http://yaml.org/>`_ format. This is similar in purpose to JSON, but easier to read and write. Here is an example config file in YAML:

.. code-block:: yaml

    # Awe config - see http://awe.alberon.co.uk/ for documentation

    ASSETS:

        # This is a comment
        default:
            src:        www/wp-content/themes/mytheme/src/
            dest:       www/wp-content/themes/mytheme/build/
            bower:      false
            sourcemaps: true

Note how indentation is used to determine the structure, similar to Python and CoffeeScript, and strings do not need to be quoted. It also supports real comments, unlike JSON.

You shouldn't need to understand YAML in detail to configure Awe -- just follow the examples -- but if you would like to learn more about it please see `Wikipedia <http://en.wikipedia.org/wiki/YAML>`_ or the `official YAML specification <http://www.yaml.org/spec/1.2/spec.html#Preview>`_.

.. note::

    For comparison, the equivalent config file in JSON would be:

    .. code-block:: json

        {
            "_comment": "Awe config - see http://awe.alberon.co.uk/ for documentation",

            "ASSETS": {

                "_comment": "This is a comment (http://stackoverflow.com/a/244858/167815)",
                "theme": {
                    "src":        "www/wp-content/themes/mytheme/src/",
                    "dest":       "www/wp-content/themes/mytheme/build/",
                    "bower":      false,
                    "sourcemaps": true
                }

            }
        }

    But this is just an illustration -- JSON is *not* supported by Awe.


================================================================================
 Config sections
================================================================================

The config file is designed to be split into sections. Each top-level section is written in UPPERCASE to make it stand out:

.. code-block:: yaml

    ASSETS:

        # Asset groups config

For more information about the settings available, see:

- :doc:`assets`
- :ref:`Quick reference <reference-config>`

.. admonition:: Future Plans
    :class: note

    Currently the only section supported is ``ASSETS``, but in the future the config file may look something like this:

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
