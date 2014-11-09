###########
 Changelog
###########

.. role:: date
   :class: changelogdate

.. role:: future
   :class: changelogfuture

.. raw:: html

  <style>
  .changelogdate { font-size: 70%; }
  .changelogfuture { color: #b65a5a; }
  </style>

----------------------------
 :future:`Upcoming release`
----------------------------

- Add support for Autoprefixer
- ...

-----------------------------
 v0.0.5_ :date:`(7 Sep 2014)`
-----------------------------

.. _v0.0.5: https://github.com/davejamesmiller/awe/tree/v0.0.5

- Don't attempt to rewrite URLs inside CSS comments
- Prevent ``awe watch`` crashing when multiple files are changed at once (by debouncing and queuing)
- Use ``fs.watch()`` instead of ``fs.watchFile()`` for watching file changes - triggers much faster

-----------------------------
 v0.0.4_ :date:`(4 Aug 2014)`
-----------------------------

.. _v0.0.4: https://github.com/davejamesmiller/awe/tree/v0.0.4

- Add more info to ``package.json`` to display on the `npm website <https://www.npmjs.org/package/awe>`_

-----------------------------
 v0.0.3_ :date:`(4 Aug 2014)`
-----------------------------

.. _v0.0.3: https://github.com/davejamesmiller/awe/tree/v0.0.3

- Bug fix - ``rimraf`` was in ``devDependencies`` not ``dependencies``

-----------------------------
 v0.0.2_ :date:`(4 Aug 2014)`
-----------------------------

.. _v0.0.2: https://github.com/davejamesmiller/awe/tree/v0.0.2

- Compile ``.scss`` and ``.coffee`` files
- Combine ``.js`` and ``.css`` directories to a single output file
- Copy all other files unchanged
- Add ``awe help`` - display basic help
- Add ``awe init`` - create awe.yaml in the current directory
- Add ``awe version`` - display the Awe version number
- Add ``awe watch`` - watch for changes and rebuild automatically

------------------------------
 v0.0.1_ :date:`(17 May 2014)`
------------------------------

.. _v0.0.1: https://github.com/davejamesmiller/awe/tree/v0.0.1

- Proof of concept / placeholder to register the name on `npm <https://www.npmjs.org/package/awe>`_
