################################################################################
 Asset building
################################################################################

.. only:: html

  .. contents::
    :local:


================================================================================
 Getting started
================================================================================

----------------------------------------
 Create your source directory
----------------------------------------

First, create a directory for your source files. Let's say you're making a `WordPress <https://wordpress.org/>`_ theme - you would create a subdirectory named ``src/`` in your theme as follows:

.. code-block:: bash

    $ mkdir www/wp-content/themes/mytheme/src/


----------------------------------------
 Configuration
----------------------------------------

Next, add the following to the ``awe.yaml`` :doc:`configuration file <config>`, replacing the paths as necessary:

.. code-block:: yaml

    ASSETS:

        default:
            src:          www/wp-content/themes/mytheme/src/
            dest:         www/wp-content/themes/mytheme/build/
            bower:        false
            autoprefixer: false

.. warning::

    The ``build/`` directory **should not** be an existing directory -- anything inside it will be deleted.

.. tip::

    The ``src/`` directory can be outside the document root if you prefer. e.g. The recommended directory layout for `Laravel <http://laravel.com/>`_ 5 is:

    .. code-block:: yaml

        ASSETS:

            default:
                src:          resources/assets/    # app/assets/ in Laravel 4
                dest:         public/assets/

    Be aware that the original source code will still be made public (in the source maps), so this is not a way to hide it.


----------------------------------------
 Create your source files
----------------------------------------

All your source files should go into the ``src/`` directory you created above. For now, let's imagine you have these files::

    src/
    ├── img/
    │   └── logo.png
    ├── sample1.css
    ├── sample2.js
    └── subdirectory/
        ├── A.css
        └── B.js


----------------------------------------
 Run the build command
----------------------------------------

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


.. _autoprefixer:

================================================================================
 Autoprefixer
================================================================================

`Autoprefixer <https://github.com/postcss/autoprefixer>`__ automatically adds vendor prefixes (``-webkit-``, ``-moz-``, etc.) to your CSS files. Simply enable it in the config:

.. code-block:: yaml
    :emphasize-lines: 7

    ASSETS:

        default:
            src:          www/wp-content/themes/mytheme/src/
            dest:         www/wp-content/themes/mytheme/build/
            bower:        false
            autoprefixer: true

For more details about how it works, and how to selectively disable it, see the `Autoprefixer documentation <https://github.com/postcss/autoprefixer#readme>`_.


================================================================================
 CoffeeScript
================================================================================

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

.. tip::

    It will also generate source maps -- ``sample.js.map`` and ``subdirectory/A.js.map`` -- but these are not shown for simplicity.

For more details see the `CoffeeScript documentation <http://coffeescript.org/>`_.


================================================================================
 Sass
================================================================================

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

For more details see the `Sass documentation <http://sass-lang.com/guide>`_.

.. note::

    Only the *SCSS* format is supported by Awe, not the original *Sass* indented format (i.e. ``.sass`` files), because it's easier for people used to regular CSS to pick up.


================================================================================
 Ignored files (partials)
================================================================================

Awe ignores all files and directories that start with an underscore (``_``). In Sass this is used to ``@import`` `partials <http://sass-lang.com/guide#topic-4>`_ -- for example, this directory structure::

    src/
    ├── _partials/
    │   └── reset.scss
    ├── _vars.scss
    └── styles.scss

Will result in this output::

    build/
    └── styles.css

.. note::

    Although this is mostly used for Sass partials, Awe will ignore **any** file or directory that starts with an underscore.


================================================================================
 Compass
================================================================================

`Compass <http://compass-style.org/>`_ is a popular CSS framework built on top of Sass. To use it, simply ``@import`` the file shown in the `Compass documentation <http://compass-style.org/reference/compass/>`_ at the top of your ``.scss`` file. For example:

.. code-block:: scss

    @import 'compass/typography/links/unstyled-link';

    .footer a {
        @include unstyled-link;
    }

This is compiled to:

.. code-block:: css

    .footer a {
        color: inherit;
        text-decoration: inherit;
        cursor: inherit;
    }

    .footer a:active, .footer a:focus {
        outline: none;
    }

.. tip::

    While it is possible to use ``@import 'compass';`` as a short-hand, this is noticably slower to build than importing only the specific features required.

.. tip::

    Many of the Compass mixins simply add `vendor prefixes for CSS3 <http://compass-style.org/reference/compass/css3/>`_. Instead of using these, I recommend enabling `autoprefixer`_.

.. note::

    You may need to be aware of the following `Compass configuration options <http://compass-style.org/help/documentation/configuration-reference/>`_ that Awe uses:

    .. code-block:: ruby

        images_path      = 'src/img/'                     # used by image-url(), inline-image(), etc.
        fonts_path       = 'src/fonts/'                   # used by font-url(), inline-font-files(), etc.
        sprite_load_path = ['src/img/', 'src/_sprites/']  # used for sprite generation (see below)

    This means images should be kept in a folder called ``img/``, font files in ``fonts/`` and sprites in ``_sprites/``.


================================================================================
 Sprites
================================================================================

Compass has the ability to take several small icons and combine them into a single image, then use that as a sprite in your CSS.

To do this, first create a directory inside ``src/_sprites/`` with the name of the sprite -- e.g. ``src/_sprites/navbar/``. Inside that directory create a PNG image for each icon. You can also have variants ending with ``_hover``, ``_active`` and ``_target`` which map to ``:hover``, ``:active`` and ``:target`` in the CSS. So, for example, you may have a directory structure like this::

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


----------------------------------------
 Advanced spriting
----------------------------------------

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

.. note::

    The Compass documentation uses ``images/`` as the base directory, whereas Awe recommends using ``_sprites/``. You can also put them in the ``img/`` directory if you prefer, but in that case the source images will be copied to the build directory as well.


.. _combined-directories:

================================================================================
 Combining files
================================================================================

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

.. caution::

    It is best to avoid mixing subdirectories and files, as some programs display all subdirectories first which may be confusing:

    - ``subdirectory/`` (2)
    - ``file.css`` (1)
    - ``vendor.css`` (3)


.. _yaml-import:

================================================================================
 Import files
================================================================================

Another way to combine multiple files is to create an import file -- this is a YAML file with the extension ``.css.yaml`` or ``.js.yaml`` containing a list of files to import. This is mostly useful for importing vendor files::

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


================================================================================
 Bower support
================================================================================

`Bower <http://bower.io/>`_ is a package manager for third-party assets. It makes it easier to install and upgrade frontend dependencies such as jQuery and Bootstrap.


----------------------------------------
 Create bower.json
----------------------------------------

Make sure you have a ``bower.json`` file -- if not, run this to create one:

.. code-block:: bash

    $ cd /path/to/repo
    $ echo '{"name":"app","private":true}' > bower.json

.. admonition:: Future Plans
    :class: note

    I plan to add a command to generate this file, e.g. ``awe init bower``, because ``bower init`` asks far more questions than are necessary!


----------------------------------------
 Find packages
----------------------------------------

To find a package on Bower, run:

.. code-block:: bash

    $ bower search <name>

Or use the `online package search <http://bower.io/search/>`_.


----------------------------------------
 Install the packages you want
----------------------------------------

To install a package, run this:

.. code-block:: bash

    $ bower install --save <name>

Sometimes you may need to specify a version number -- e.g. jQuery will default to the 2.x branch which does not support IE8:

.. code-block:: bash

    $ bower install --save jquery#1.x

This will create a ``bower_components/`` directory in the project root (same directory as ``awe.yaml``) containing the package and any dependencies.

.. tip::

    If the package you want is not registered with Bower, you can install it from another source:

    .. code-block:: bash

        $ bower install --save user/repo                        # From GitHub
        $ bower install --save http://example.com/script.js     # From a URL
        $ bower install --save http://example.com/package.zip   # From a zip

    For more details, please see the `Bower install documentation <http://bower.io/docs/api/#install>`_.

.. note::

    The installed packages should be checked into the Git repository, not ignored, to ensure the same version is installed on the live site. This advice may change in the future when `bower.lock <https://github.com/bower/bower/pull/1592>`_ is implemented (and/or ``awe deploy`` is ready).


----------------------------------------
 Update the config file
----------------------------------------

Update ``awe.yaml`` with the path to the Bower components directory:

.. code-block:: yaml
    :emphasize-lines: 6

    ASSETS:

        default:
            src:          www/wp-content/themes/mytheme/src/
            dest:         www/wp-content/themes/mytheme/build/
            bower:        bower_components/
            autoprefixer: false


----------------------------------------
 Import the files you need
----------------------------------------

Create a ``.js.yaml`` or ``.css.yaml`` `import file <#import-files>`_ (e.g. ``src/jquery.js.yaml``), for example:

.. code-block:: yaml

    - bower: jquery/jquery.js

This will be compiled to ``build/jquery.js``.

.. note::

    An alternative is to load the file you need directly in your HTML, using the ``_bower/`` symlink that is created:

    .. code-block:: html

        <script src="/assets/_bower/jquery/jquery.min.js"></script>


----------------------------------------
 Combining Bower and non-Bower files
----------------------------------------

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


----------------------------------------
 Updating packages
----------------------------------------

To check for outdated dependencies:

.. code-block:: bash

    $ bower list

To update them, first update ``bower.json`` if necessary (if you have specified a particular version to use), then run:

.. code-block:: bash

    $ bower update

For more details, please see the `Bower documentation <http://bower.io/docs/api/>`_.


================================================================================
 Multiple asset groups
================================================================================

To compile assets in multiple directories, simply add another group with a different name:

.. code-block:: yaml
    :emphasize-lines: 3, 11

    ASSETS:

        theme:
            src:          www/wp-content/themes/mytheme/src/
            dest:         www/wp-content/themes/mytheme/build/
            bower:        false
            autoprefixer: false

        plugin:
            src:          www/wp-content/plugins/myplugin/src/
            dest:         www/wp-content/plugins/myplugin/build/
            bower:        false
            autoprefixer: true

Reasons to do this include:

- Multiple themes/plugins in a single project
- Different config settings for different assets
- Speed up ``watch`` builds by only rebuilding one directory at a time

The group name must be alphanumeric (``[a-zA-Z0-9]+``).

.. admonition:: Future Plans
    :class: note

    The group name is not currently used anywhere, but in the future it may be possible to build individual directories (e.g. ``awe build theme``).
