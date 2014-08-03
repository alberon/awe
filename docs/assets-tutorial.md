# Assets tutorial

## Initial setup

### Create your source directory

First, create a directory for your source files. Let's say you're making a WordPress theme, so you would create a subdirectory named `src/` in your theme:

```bash
$ mkdir www/wp-content/themes/mytheme/src/
```

**Tip:** If you prefer, you can keep the `src/` directory outside the document root - e.g. `app/assets/` in Laravel.

### Configuration

Next, add the following to [`awe.yaml`](start-config.md), altering the paths as necessary:

```yaml
assets:
    theme:
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/dist/
```

**Note:** The `dist/` directory **should not** be an existing directory as anything inside will be deleted.

### Create your source files

All your source files should go into the `src/` directory you created above. For now, let's imagine you have these files:

```
src/
├── img/
│   └── logo.png
├── sample1.css
├── sample2.js
└── subdirectory/
    ├── A.css
    └── B.js
```

### Run the `build` command

Finally, run this command to generate the `dist/` directory:

```bash
$ awe build
```

Since there are no special files in the list above, you will get exactly the same structure:

```
dist/
├── img/
│   └── logo.png
├── sample1.css
├── sample2.js
└── subdirectory/
    ├── A.css
    └── B.js
```

However, read on to see what Awe can do!

## CoffeeScript

[CoffeeScript](http://coffeescript.org/) is "a little language that compiles into JavaScript". It has a very simple 1-to-1 mapping of input files (`.coffee`) to output files (`.js`). For example, these source files:

```
src/
├── sample.coffee
└── subdirectory/
    └── A.coffee
```

Would result in this output:

```
dist/
├── sample.js
└── subdirectory/
    └── A.js
```

## Sass

[Sass](http://sass-lang.com/) is an extension to CSS, and compiles `.scss` files to `.css`. For example, these source files:

```
src/
├── sample.scss
└── subdirectory/
    └── A.scss
```

Would result in this output:

```
dist/
├── sample.css
└── subdirectory/
    └── A.css
```

## Ignoring partials

Sass has the ability to `@import` other files ([partials](http://sass-lang.com/guide#topic-4)). Typically you do not want these to be compiled into their own CSS files. Awe ignores *all* files and directories that start with an underscore (`_`), so all you need to do is follow this convention. For example:

```
src/
├── _partials/
│   └── reset.scss
├── _vars.scss
└── styles.scss
```

Will result in this output:

```
dist/
└── styles.css
```

**Note:** This also applies to other file types - use an underscore for any files and directories you want Awe to ignore.

## Compass

[Compass](http://compass-style.org/) is a popular CSS framework built on top of Sass. To use it, simply `@import` the file shown in the [Compass documentation](http://compass-style.org/reference/compass/) at the top of your `.scss` file. For example:

```scss
@import 'compass/css3/border-radius';

.sample {
    @include border-radius(4px);
}
```

This is compiled to:

```css
.sample {
  -webkit-border-radius: 4px;
  -moz-border-radius: 4px;
  -ms-border-radius: 4px;
  border-radius: 4px;
}
```

**Tip:** It is possible to use `@import 'compass';` as a short-hand, **but** this is noticably slower than importing only the specific features required.

### Compass configuration

You may need to be aware of the following configuration options that Awe uses:

- `images_path` is set to `<src dir>/img/` - this is used by [`image-url()`](http://compass-style.org/reference/compass/helpers/urls/), [`inline-image()`](http://compass-style.org/reference/compass/helpers/inline-data/) and related functions
- `fonts_path` is set to `<src dir>/fonts/` - this is used by [`font-url()`](http://compass-style.org/reference/compass/helpers/urls/), [`inline-font-files()`](http://compass-style.org/reference/compass/helpers/inline-data/) and related functions

## Sprites

Compass has the ability to take several small icons and combine them into a single image, then use that as a sprite in your CSS.

To do this, first create a directory inside `src/img/` with the name of the sprite - e.g. `src/img/navbar/`. Inside that directory create a PNG image for each icon. You can also have variants ending with `_hover`, `_active` and `_target` which map to `:hover`, `:active` and `:target` in the CSS. So, for example, you may have a directory structure like this:

```
src/
├── img/
│   └── navbar/
│       ├── edit.png
│       ├── edit_hover.png
│       ├── ...
│       ├── save.png
│       └── save_hover.png
└── sample.scss
```

Then in the SCSS file enter the following:

```scss
@import 'compass/utilities/sprites';
@import 'navbar/*.png';              // This path is relative to the img/ directory
@include all-navbar-sprites;         // Replace 'navbar' with the directory name
```

This will generate a directory structure similar to the following:

```
src/
├── _generated/
│   └── navbar-s71af1c7425.png
├── img/
│   └── navbar/
│       ├── edit.png
│       ├── edit_hover.png
│       ├── ...
│       ├── save.png
│       └── save_hover.png
└── sample.css
```

**Note:** The `img/navbar/` directory is not really needed, but there is currently no easy way to prevent it being generated.

And the following classes will appear in the output file, ready for you to use in your HTML:

```css
/* Replace 'navbar' with the directory name */
.navbar-delete       { ... }
.navbar-delete:hover { ... }
.navbar-edit         { ... }
.navbar-edit:hover   { ... }
.navbar-new          { ... }
.navbar-new:hover    { ... }
.navbar-save         { ... }
.navbar-save:hover   { ... }
```

For further details (and more complex scenarios), please see the Compass [spriting documentation](http://compass-style.org/help/tutorials/spriting/). However, be aware that the Compass documentation refers to `images/`, whereas Awe uses `img/`.

## Combining files

Awe can automatically combine multiple CSS/JavaScript files into a single file, allowing you to split the source files up neatly while reducing the number of downloads for end users.

Awe does this based on the directory structure, not with a config file, to make it really easy to understand and maintain the source files. Simply create a directory with a name that ends `.css` or `.js` and all the files within that directory will be concatenated (in alphabetical order) into a single output file. For example:

```
src/
└── combined.css/
    ├── 1.css
    ├── 2.scss
    └── 3/
        ├── A.css
        └── B.scss
```

First the `.scss` files will be compiled to CSS, then all 4 files will be combined (in the order `1.css`, `2.scss`, `3/A.css`, `3/B.scss`) into a single `combined.css` file:

```
dist/
└── combined.css
```

Simple as that!

**Note:** It is best to avoid mixing subdirectories and files, as some programs display all subdirectories first which may be confusing. If you do mix them, it's best to number them all to make it clear what order they are loaded in (e.g. `1-subdirectory/`, `2-file.js`, `3-another-directory/`).

## Bower

[Bower](http://bower.io/) is a package manager for third-party assets. It makes it easier to install and upgrade frontend dependencies such as jQuery and Bootstrap.

### Installing packages

Install the packages you need using Bower, for example:

```bash
$ cd /path/to/repo
$ bower install jquery#1.x
```

This will create `bower_components/` directory in the project root (same directory as `awe.yaml`) containing package and any dependencies.

For more details, please see the [Bower documentation](http://bower.io/).

### Configure Awe

To enable Bower support in Awe, add `bower: true` to the asset group in the config file (`awe.yaml`) - for example:

```yaml
assets:
    theme:
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/dist/
        bower: true
```

### Create symlinks to the files

Finally, create a symlink from the `src/` directory to any file you want available. For example:

```bash
$ cd www/wp-content/themes/mytheme/src/
$ ln -s ../../../../../bower_components/jquery/dist/jquery.js jquery.js
```

**Note:** You must use a **relative** path when creating the symlink, else it will break when installed in a different location.

You can do the same with CSS files - Awe will automatically create a symlink and rewrite any relative URLs to images.

### Combining Bower and non-Bower files

You can easily combine Bower files with custom files, as described above. For example (`->` indicates a symlink):

```
src/
├── app.css/
│   ├── 1-jquery-ui.css  ->  ..../bower_components/jquery-ui/themes/ui-lightness/jquery-ui.css
│   └── 2-custom.scss
└── app.js/
    ├── 1-jquery.js      ->  ..../bower_components/jquery/dist/jquery.js
    ├── 2-jquery-ui.js   ->  ..../bower_components/jquery-ui/jquery-ui.js
    └── 3-custom.coffee
```

Will result in:

```
dist/
├── _bower/     ->  ..../bower_components/
├── app.css
└── app.js
```

The URLs from `jquery-ui.css` (now in `app.css`) will automatically be rewritten to the form `url(_bower/jquery-ui/..../<filename>.png)`.
