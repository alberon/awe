################################################################################
 Cache files
################################################################################

Awe will create a hidden directory named ``.awe`` inside each project, which is used to hold cache files. This directory will automatically be ignored by Git (Awe will create a ``.awe/.gitignore`` file), but you may want to configure your editor to hide it.


================================================================================
 Hiding in Sublime Text
================================================================================

In Sublime Text, go to Project > Edit Project and add a ``folder_exclude_patterns`` section:

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
