################
 Asset building
################

.. only:: html

    .. contents::
       :local:


=================
 Getting started
=================

------------------------------
 Create your source directory
------------------------------

First, create a directory for your source files. Let's say you're making a WordPress theme, so you would create a subdirectory named ``src/`` in your theme:

.. code-block:: bash

    $ mkdir www/wp-content/themes/mytheme/src/

**Tip:** If you prefer, you can keep the ``src/`` directory outside the document root - e.g. ``app/assets/`` in Laravel.

---------------
 Configuration
---------------

Next, add the following to the ``awe.yaml`` configuration file, altering the paths as necessary:

.. code-block:: yaml

    theme:
        src:  www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/build/

**Note:** The ``build/`` directory **should not** be an existing directory as anything inside will be deleted.

--------------------------
 Create your source files
--------------------------

All your source files should go into the ``src/`` directory you created above. For now, let's imagine you have these files::

    src/
    ├── img/
    │   └── logo.png
    ├── sample1.css
    ├── sample2.js
    └── subdirectory/
        ├── A.css
        └── B.js

-----------------------
 Run the build command
-----------------------

Finally, run the ``build`` command to generate the ``build/`` directory:

.. code-block:: bash

    $ awe build

Or run the ``watch`` command to generate it and then wait for further changes:

.. code-block:: bash

    $ awe watch

Since there are no special files in the list above, you will get exactly the same structure::

    build/
    ├── img/
    │   └── logo.png
    ├── sample1.css
    ├── sample2.js
    └── subdirectory/
        ├── A.css
        └── B.js

However, read on to see what Awe can do!


==============
 CoffeeScript
==============

`CoffeeScript <http://coffeescript.org/>`_ is "a little language that compiles into JavaScript". It has a very simple 1-to-1 mapping of input files (``.coffee``) to output files (``.js``). For example, these source files::

    src/
    ├── sample.coffee
    └── subdirectory/
        └── A.coffee

Would result in this output::

    build/
    ├── sample.js
    └── subdirectory/
        └── A.js


======
 Sass
======

`Sass <http://sass-lang.com/>`_ is an extension to CSS, and compiles ``.scss`` files to ``.css``. For example, these source files::

    src/
    ├── sample.scss
    └── subdirectory/
        └── A.scss

Would result in this output::

    build/
    ├── sample.css
    └── subdirectory/
        └── A.css

--------------------------
 Ignored files (partials)
--------------------------

Sass has the ability to ``@import`` other files (`partials <http://sass-lang.com/guide#topic-4>`_). Typically you do not want these to be compiled into their own CSS files. Awe ignores *all* files and directories that start with an underscore (``_``), so all you need to do is follow this convention. For example::

    src/
    ├── _partials/
    │   └── reset.scss
    ├── _vars.scss
    └── styles.scss

Will result in this output::

    build/
    └── styles.css

**Note:** This also applies to other file types - use an underscore for any files and directories you want Awe to ignore.


=========
 Compass
=========

`Compass <http://compass-style.org/>`_ is a popular CSS framework built on top of Sass. To use it, simply ``@import`` the file shown in the `Compass documentation <http://compass-style.org/reference/compass/>`_ at the top of your ``.scss`` file. For example:

.. code-block:: scss

    @import 'compass/css3/border-radius';

    .sample {
        @include border-radius(4px);
    }

This is compiled to:

.. code-block:: css

    .sample {
        -webkit-border-radius: 4px;
        -moz-border-radius: 4px;
        -ms-border-radius: 4px;
        border-radius: 4px;
    }

**Tip:** It is possible to use ``@import 'compass';`` as a short-hand, **but** this is noticably slower than importing only the specific features required.

-----------------------
 Compass configuration
-----------------------

You may need to be aware of the following configuration options that Awe uses:

- ``images_path = 'src/img/'`` (used by `image-url()`_, `inline-image()`_ and related functions)
- ``fonts_path = 'src/fonts/'`` (used by `font-url()`_, `inline-font-files()`_ and related functions)
- ``sprite_load_path = ['src/img/', 'src/_sprites/']`` (used for `sprite generation <#sprites>`_)

.. _image-url():         http://compass-style.org/reference/compass/helpers/urls/#image-url
.. _inline-image():      http://compass-style.org/reference/compass/helpers/inline-data/#inline-image
.. _font-url():          http://compass-style.org/reference/compass/helpers/urls/#font-url
.. _inline-font-files(): http://compass-style.org/reference/compass/helpers/inline-data/#inline-font-files


=========
 Sprites
=========

Compass has the ability to take several small icons and combine them into a single image, then use that as a sprite in your CSS.

To do this, first create a directory inside ``src/_sprites/`` with the name of the sprite - e.g. ``src/_sprites/navbar/``. Inside that directory create a PNG image for each icon. You can also have variants ending with ``_hover``, ``_active`` and ``_target`` which map to ``:hover``, ``:active`` and ``:target`` in the CSS. So, for example, you may have a directory structure like this::

    src/
    ├── _sprites/
    │   └── navbar/
    │       ├── edit.png
    │       ├── edit_hover.png
    │       ├── ...
    │       ├── save.png
    │       └── save_hover.png
    └── sample.scss

Then in the SCSS file enter the following:

.. code-block:: scss

    @import 'compass/utilities/sprites';
    @import 'navbar/*.png';              // This path is relative to the _sprites/ directory
    @include all-navbar-sprites;         // Replace 'navbar' with the directory name

This will generate a directory structure similar to the following::

    build/
    ├── _generated/
    │   └── navbar-s71af1c7425.png
    └── sample.css

And the following classes will appear in the output file, ready for you to use in your HTML:

.. code-block:: css

    /* Replace 'navbar' with the directory name */
    .navbar-delete       { ... }
    .navbar-delete:hover { ... }
    .navbar-edit         { ... }
    .navbar-edit:hover   { ... }
    .navbar-new          { ... }
    .navbar-new:hover    { ... }
    .navbar-save         { ... }
    .navbar-save:hover   { ... }

-------------------
 Advanced spriting
-------------------

If you require more control over the classes that are generated, there are several other ways to create them. For example:

.. code-block:: scss

    @import 'compass/utilities/sprites';

    $navbar-map: sprite-map('navbar/*.png');

    .navbar {
        background: $navbar-map;
    }

    @each $sprite in sprite-names($navbar-map) {
        .navbar-#{$sprite} {
            @include sprite($navbar-map, $sprite, true);
        }
    }

For more details, please see the Compass `spriting documentation`_, `options`_ and `mixins`_.

.. _spriting documentation: http://compass-style.org/help/tutorials/spriting/
.. _options:                http://compass-style.org/help/tutorials/spriting/customization-options/
.. _mixins:                 http://compass-style.org/reference/compass/utilities/sprites/base/

.. highlights::

    **Note:** The Compass documentation uses ``images/`` as the base directory, whereas Awe uses ``_sprites/`` (or ``img/``).


=================
 Combining files
=================

Awe can automatically combine multiple CSS/JavaScript files into a single file, allowing you to split the source files up neatly while reducing the number of downloads for end users.

Simply create a directory with a name that ends ``.css`` or ``.js`` and all the files within that directory will be concatenated (in alphabetical/numerical order) into a single output file. For example::

    src/
    └── combined.css/
        ├── 1.css
        ├── 2/
        │   ├── A.css
        │   └── B.scss
        └── 3.scss

First the ``.scss`` files will be compiled to CSS, then all 4 files will be combined (in the order ``1.css``, ``2/A.css``, ``2/B.scss``, ``3.scss``) into a single ``combined.css`` file::

    build/
    └── combined.css

Simple as that!

**Note:** It is best to avoid mixing subdirectories and files, as some programs display all subdirectories first which may be confusing. If you do mix them, it's best to number them all to make it clear what order they are loaded in (e.g. ``1-subdirectory/``, ``2-file.js``, ``3-another-directory/``).


==============
 Import files
==============

Another way to combine multiple files is to create an import file - this is a YAML file with the extension ``.css.yaml`` or ``.js.yaml`` containing a list of files to import. This is mostly useful for importing vendor files::

    src/
    └── vendor.js.yaml

    vendor/
    ├── chosen.js
    └── jquery.js

Where ``vendor.js.yaml`` contains:

.. code-block:: yaml

    - ../vendor/jquery.js
    - ../vendor/chosen.js

Will compile to::

    build/
    └── vendor.js

To import files from Bower (`see below <#using-bower>`_), simply prefix the filename with ``bower:``:

.. code-block:: yaml

    - bower: jquery/jquery.js
    - bower: jquery-ui/ui/jquery-ui.js


=============
 Using Bower
=============

`Bower <http://bower.io/>`_ is a package manager for third-party assets. It makes it easier to install and upgrade frontend dependencies such as jQuery and Bootstrap.

---------------------
 Installing packages
---------------------

Install the packages you need using Bower as normal - for example:

.. code-block:: bash

    $ cd /path/to/repo
    $ bower install jquery#1.x

This will create ``bower_components/`` directory in the project root (same directory as ``awe.yaml``) containing the package and any dependencies.

For more details, please see the `Bower documentation <http://bower.io/>`_.

---------------------------
 Import the files you need
---------------------------

Create a ``.js.yaml`` or ``.css.yaml`` `import file <#import-files>`_ (e.g. ``src/jquery.js.yaml``), for example:

.. code-block:: yaml

    - bower: jquery/jquery.js

This will be compiled to ``build/jquery.js``.

-------------------------------------
 Combining Bower and non-Bower files
-------------------------------------

You can easily combine Bower files with custom files, as described above. For example::

    src/
    ├── app.css/
    │   ├── 1-import.css.yaml   ==>   - bower: jquery-ui/themes/smoothness/jquery-ui.css
    │   └── 2-custom.scss
    └── app.js/
        ├── 1-import.js.yaml    ==>   - bower: jquery/jquery.js
        │                             - bower: jquery-ui/ui/jquery-ui.js
        └── 2-custom.coffee

Will result in::

    build/
    ├── _bower/  ->  ..../bower_components/
    ├── app.css
    └── app.js

(``->`` indicates a symlink.)

The URLs from ``jquery-ui.css`` (now in ``app.css``) will automatically be rewritten to ``url(_bower/jquery-ui/themes/smoothness/<filename>)``.

-------------------
 Custom Bower path
-------------------

If the Bower components are installed somewhere other than ``bower_components/`` (relative to ``awe.yaml``) you can specify a custom location in ``awe.yaml``:

.. code-block:: yaml

    theme:
        src:   www/wp-content/themes/mytheme/src/
        dest:  www/wp-content/themes/mytheme/build/
        bower: www/wp-content/themes/mytheme/bower_components/
