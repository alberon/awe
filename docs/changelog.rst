################################################################################
 Changelog
################################################################################

.. role:: date
    :class: changelog-date

.. role:: future
    :class: changelog-future


.. ================================================================================
..  :future:`Upcoming release`
.. ================================================================================

================================================================================
 v0.1.0_ :date:`(16 Nov 2014)`
================================================================================

.. _v0.1.0: https://github.com/alberon/awe/tree/v0.1.0

*First beta version:*

- Major rewrite to improve maintainability
- Switch to Read The Docs (Sphinx) for documentation and rewrote a lot of it
- Change config file format (**note:** existing config files will need updating)
- Added source maps
- Added Autoprefixer
- Added YAML import files
- Removed URL rewriting when following symlinks (too confusing)
- Added config file validation (to help catch errors)
- Added support for custom Bower path
- Improved error handling/reporting


================================================================================
 v0.0.5_ :date:`(7 Sep 2014)`
================================================================================

.. _v0.0.5: https://github.com/alberon/awe/tree/v0.0.5

- Don't attempt to rewrite URLs inside CSS comments
- Prevent ``awe watch`` crashing when multiple files are changed at once (by debouncing and queuing)
- Use ``fs.watch()`` instead of ``fs.watchFile()`` for watching file changes - triggers much faster


================================================================================
 v0.0.4_ :date:`(4 Aug 2014)`
================================================================================

.. _v0.0.4: https://github.com/alberon/awe/tree/v0.0.4

- Add more info to ``package.json`` to display on the `npm website <https://www.npmjs.org/package/awe>`_


================================================================================
 v0.0.3_ :date:`(4 Aug 2014)`
================================================================================

.. _v0.0.3: https://github.com/alberon/awe/tree/v0.0.3

- Bug fix - ``rimraf`` was in ``devDependencies`` not ``dependencies``


================================================================================
 v0.0.2_ :date:`(4 Aug 2014)`
================================================================================

.. _v0.0.2: https://github.com/alberon/awe/tree/v0.0.2

*First alpha version:*

- Compile ``.scss`` and ``.coffee`` files
- Combine ``.js`` and ``.css`` directories to a single output file
- Copy all other files unchanged
- Add ``awe help`` - display basic help
- Add ``awe init`` - create awe.yaml in the current directory
- Add ``awe version`` - display the Awe version number
- Add ``awe watch`` - watch for changes and rebuild automatically


================================================================================
 v0.0.1 :date:`(17 May 2014)`
================================================================================

- Proof of concept / placeholder to register the name on `npm <https://www.npmjs.org/package/awe>`_
