# Assets

## Features

Awe can:

- Compile [Sass](http://sass-lang.com/)/[Compass](http://compass-style.org/) (`.scss`) files to CSS
- Compile [CoffeeScript](http://coffeescript.org/) (`.coffee`) files to JavaScript
- Combine multiple JavaScript/CSS source files into a single file
- Automatically rewrite relative URLs in CSS files that are combined or use symlinks (including to Bower)

### Coming soon

It cannot yet (but hopefully will in the near future):

- Generate [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/)
- [Autoprefix](https://github.com/ai/autoprefixer) CSS rules for easy cross-browser compatibility
- Minify JS/CSS files
- Compress images
- [Automatically reload](http://livereload.com/) the browser
- Display Growl notifications when there are build errors
- Have an interactive menu for less technical frontend developers

## Tutorial

### Initial setup

Let's say you're making a WordPress theme. First, create a subdirectory named `src/` in your theme - that's where we'll put the source files:

```bash
$ mkdir www/wp-content/themes/mytheme/src/
```

(If you prefer, you can keep the `src/` directory outside the document root so end users cannot read the source files.)

Then put the following into `awe.yaml` in your project root directory, altering the paths as necessary:

```yaml
assets:
    theme:
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/dist/
```

The `dist/` directory does not need to be created, and it **should not** be an existing directory with files in as they would be deleted.

All your source files should go into the `src/` directory you created above. For now, let's start with some simple files:

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

Then run this command to generate the `dist/` directory:

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

However, read on to see magic happen!

### Compiling CoffeeScript

Let's start with a very simple one - [CoffeeScript](http://coffeescript.org/). CoffeeScript is "a little language that compiles into JavaScript". It has a very simple 1-to-1 mapping of input files (`.coffee`) to output files (`.js`). For example:

```
src/
├── sample.coffee
└── subdirectory/
    └── A.coffee
```

Will result in:

```
dist/
├── sample.js
└── subdirectory/
    └── A.js
```

### Compiling Sass and ignoring partials

[Sass](http://sass-lang.com/) is an extension to CSS, and similarly compiles `.scss` to `.css`.

Unlike CoffeeScript, Sass also has the ability to `@import` [partials](http://sass-lang.com/guide#topic-4) - these are files that should not be compiled into a CSS file.

Awe ignores *all* files and directories that start with an underscore (`_`). For example:

```
src/
├── _partials/
│   └── reset.scss
├── _vars.scss
├── styles.scss
└── subdirectory/
    └── another.scss
```

Will result in:

```
dist/
├── styles.css
└── subdirectory/
    └── another.css
```

### Using Compass

Awe includes support for [Compass](http://compass-style.org/), a popular CSS framework built on top of Sass. To use it, simply `@import` the required file shown in the [Compass documentation](http://compass-style.org/reference/compass/) - for example:

```scss
@import 'compass/css3/border-radius';

.sample {
    @include border-radius(4px);
}
```

**Note:** It is also possible to use `@import 'compass';` as a short-hand to import everything, but this is noticably slower than importing only the specific features required.

You may need to be aware of the following configuration options that Awe uses:

- `images_path` is set to `<src dir>/img/` - this is used by [`image-url()`](http://compass-style.org/reference/compass/helpers/urls/), [`inline-image()`](http://compass-style.org/reference/compass/helpers/inline-data/) and related functions
- `fonts_path` is set to `<src dir>/fonts/` - this is used by [`font-url()`](http://compass-style.org/reference/compass/helpers/urls/), [`inline-font-files()`](http://compass-style.org/reference/compass/helpers/inline-data/) and related functions

### Generating sprites with Compass

Compass has the ability to take several small icons and combine them into a single large image, then use that as a sprite.

To do this, first create a directory inside `src/img/` with the name of the sprite - e.g. `myicon/` - and inside that add an image for each icon. You can also have variants ending with `_hover`, `_active` and `_target` which map to the `:hover`, `:active` and `:target` pseudo-classes. So you would have a directory structure like this:

```
src/
├── img/
│   └── myicon/
│       ├── delete.png
│       ├── delete_hover.png
│       ├── edit.png
│       ├── edit_hover.png
│       ├── new.png
│       ├── new_hover.png
│       ├── save.png
│       └── save_hover.png
└── sample.scss
```

Then in the Sass file enter the following:

```scss
@import 'compass/utilities/sprites';
@import 'myicon/*.png';              // This is relative to the img/ directory
@include all-myicon-sprites;         // Replace 'myicon' with the directory name
```

This will generate a directory structure similar to the following:

```
src/
├── _generated/
│   └── myicon-s71af1c7425.png
├── img/
│   └── myicon/
│       ├── delete.png
│       ├── delete_hover.png
│       ├── edit.png
│       ├── edit_hover.png
│       ├── new.png
│       ├── new_hover.png
│       ├── save.png
│       └── save_hover.png
└── sample.css
```

(**Note:** There is no way to prevent the `img/myicon/` directory being generated, even though it is not really required.)

And the following classes in the output file:

```css
/* Replace 'myicon' with the directory name */
.myicon-delete       { ... }
.myicon-delete:hover { ... }
.myicon-edit         { ... }
.myicon-edit:hover   { ... }
.myicon-new          { ... }
.myicon-new:hover    { ... }
.myicon-save         { ... }
.myicon-save:hover   { ... }
```

See the Compass [spriting documentation](http://compass-style.org/help/tutorials/spriting/) for further details and more complex scenarios. (**Note:** The image directory is set to `img/` in Awe, whereas the Compass documentation refers to `images/`.)

### Combining files

Awe can automatically combine multiple CSS/JavaScript files into a single file, reducing the number of downloads required by the end user while allowing you to split the source files up neatly.

To make it really easy to understand and maintain the source files, Awe does based on the directory structure, not with a config file. Simply create a directory with a name that ends `.css` or `.js` - all the files within that directory will be concatenated (in alphabetical order) into a single output file. For example:

```
src/
└── combined.css/
    ├── 1.css
    ├── 2.scss
    └── 3/
        ├── A.css
        └── B.scss
```

This will result in the `.scss` files being compiled to CSS, then all 4 files will be combined (in the order `1.css`, `2.scss`, `3/A.css`, `3/B.scss`) into a single `combined.css` file:

```
dist/
└── combined.css
```

Simple as that!

**Note:** It is best to avoid mixing subdirectories and files, as some programs display all subdirectories first which may be confusing. If you do mix them, it's best to number them all to make it clear what order they are loaded in.

### Using Awe with Bower

First, install the required packages using Bower:

```bash
$ cd /path/to/repo
$ bower init
$ bower install jquery#1.x --save
```

This will create a `bower.json` config file, and `bower_components/` directory in the project root (same directory as `awe.yaml`). (For more details, please see the [Bower documentation](http://bower.io/).)

Next, add `bower: true` to the asset group in `awe.yaml` - for example:

```yaml
assets:
    theme:
        src: src/
        dest: dist/
        bower: true
```

Finally, create a symlink from the `src/` directory to any file you want available. For example:

```bash
$ cd src/
$ ln -s ../bower_components/jquery/dist/jquery.js jquery.js
```

**Note:** You must use a **relative** path when creating the symlink.

You can do the same with CSS files - Awe will automatically create a symlink and rewrite any relative URLs to images.

You can also combine Bower files with custom files, as described above. For example (`->` indicates a symlink):

```
src/
├── app.css/
│   ├── 1-jquery-ui.css  ->  ../../bower_components/jquery-ui/themes/ui-lightness/jquery-ui.css
│   └── 2-custom.scss
├── app.js/
│   ├── 1-jquery.js      ->  ../../bower_components/jquery/dist/jquery.js
│   ├── 2-jquery-ui.js   ->  ../../bower_components/jquery-ui/jquery-ui.js
│   └── 3-custom.coffee
└── jquery.js            ->  ../bower_components/jquery/dist/jquery.js
```

Will result in:

```
dist/
├── _bower/     ->  ../bower_components/
├── app.css
├── app.js
└── jquery.js
```

And the URLs from `jquery-ui.css` (now in `app.css`) will be rewritten to the form `url(_bower/jquery-ui/themes/ui-lightness/images/<filename>.png)`.

## Quick reference

### Configuration

```yaml
assets:

    groupname:                  # required
        src: path/to/src/       # required
        dest: path/to/dist/     # required
        bower: true             # optional (default: false)

    anothergroup:               # optional
        ...
```

## Command-line interface

```bash
$ awe build
$ awe watch
```

### Directory structure

```
SOURCE                      DESTINATION                      NOTES
──────────────────────────  ───────────────────────────────  ───────────────────────────────────────
src/                        dist/
│                           │
│                           ├── _bower/                      Symlink to bower_components/ directory
│                           │
│                           ├── _generated/                  Compass─generated files (e.g. sprites)
│                           │   └── icon-s71af1c7425.png
│                           │
├── _partials/              │                                Directories starting with _ are ignored
│   └── reset.scss          │
│                           │
├── _vars.scss              │                                Files starting with _ are ignored
│                           │
├── combined.css/           ├── combined.css                 .css directory: files are combined
│   ├── 1.css               │
│   ├── 2.scss              │
│   └── 3-subdirectory/     │
│       ├── A.css           │
│       └── B.scss          │
│                           │
├── combined.js/            ├── combined.js                  .js directory: files are combined
│   ├── 1.js                │
│   ├── 2.coffee            │
│   └── 3-subdirectory/     │
│       ├── A.js            │
│       └── B.coffee        │
│                           │
├── img/                    ├── img/                         Images are copied unaltered
│   ├── icon/               │   ├── icon/
│   │   ├── icon1.png       │   │   ├── icon1.png
│   │   └── icon2.png       │   │   └── icon2.png
│   └── logo.png            │   └── logo.png
│                           │
├── sample1.css             ├── sample1.css                  CSS file is copied
├── sample2.scss            ├── sample2.css                  Sass file is compiled
├── sample3.js              ├── sample3.js                   JavaScript file is copied
├── sample4.coffee          ├── sample4.js                   CoffeeScript file is compiled
│                           │
└── subdirectory/           └── subdirectory/                Directory structure is kept
    ├── A.css                   ├── A.css
    ├── B.scss                  ├── B.css
    ├── C.js                    ├── C.js
    └── D.coffee                └── D.js
```
