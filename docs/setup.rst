###############
 Project setup
###############

.. contents::
   :local:


=====================
 Create ``awe.yaml``
=====================

Each project requires a single config file, ``awe.yaml``, in the root directory. A config file can be created in the current directory by running ``awe init``:

.. code-block:: bash

    $ cd /path/to/repo
    $ awe init

Then simply open ``awe.yaml`` in your preferred text editor to customise it as needed. (Alternatively you can create a config file by hand, or copy one from another project.)

.. note::

    The file is in YAML (v1.2) format. This is similar in purpose to JSON, but easier to read and write. Here is an example config file in YAML:

    .. code-block:: yaml

        theme:
            # This is a comment
            src:  www/wp-content/themes/mytheme/src/
            dest: www/wp-content/themes/mytheme/build/

    Note how indentation is used to determine the structure, similar to Python and CoffeeScript, and strings do not need to be quoted. It also supports comments, unlike JSON. The equivalent JSON file would be:

    .. code-block:: json

        {
            "theme": {
                "//":   "This is a trick to add a comment! http://stackoverflow.com/a/244858/167815",
                "src":  "www/wp-content/themes/mytheme/src/",
                "dest": "www/wp-content/themes/mytheme/build/"
            }
        }

    You shouldn't need to know any more than this to configure Awe, but if you would like to learn more about YAML, please see `Wikipedia <http://en.wikipedia.org/wiki/YAML>`_ or the `official YAML website <http://www.yaml.org/>`_.


====================
 Ignore cache files
====================

Awe will create a hidden directory named ``.awe`` inside each project, which is used to hold cache files and speed it up. This directory will automatically be ignored by Git, but you may want to configure your editor to hide it.

For example, in Sublime Text you would go to Project > Edit Project and add a ``folder_exclude_patterns`` section:

.. code-block:: json
    :emphasize-lines: 6-9

    {
        "folders":
        [
            {
                "path": ".",
                "folder_exclude_patterns":
                [
                    ".awe"
                ]
            }
        ]
    }
