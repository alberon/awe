# Awe (v0.1.0 - Beta release)

Awe is a command-line build tool for website assets - it makes it easy to compile CoffeeScript & Sass files, autoprefix CSS files and combine source files together - with full source map support for easier debugging.

It is designed for web/software development agencies and freelancers managing many different websites, so:

- It relies on convention rather than configuration, to make it easy to use and ensure consistency between sites
- It is installed system-wide, not per-project, to avoid the maintenance overhead of installing and upgrading it for each site separately

Unlike [Grunt](http://gruntjs.com/) and [Gulp](http://gulpjs.com/), Awe is not designed to be a general purpose task runner or build tool - so it won't suit everyone, but it should be much easier to configure.


## Features

- Compile [CoffeeScript](http://coffeescript.org/) (`.coffee`) files to JavaScript
- Compile [Sass](http://sass-lang.com/)/[Compass](http://compass-style.org/) (`.scss`) files to CSS
- [Autoprefix](https://github.com/ai/autoprefixer) CSS rules for easier cross-browser compatibility
- Combine multiple JavaScript/CSS source files into a single file
- Rewrite relative URLs in CSS files that are combined (e.g. packages installed with [Bower](http://bower.io/))
- Generate [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/) to aid debugging
- Watch for changes to source files and rebuild automatically
- Simple YAML configuration (no need to set up lots of separate plugins!)
- Detailed documentation
- Unit tests to ensure backwards-compatibility

### Coming soon

- Minify JavaScript & CSS files
- Optimise images
- [Automatically reload](http://livereload.com/) your web browser when assets are rebuilt
- [Growl notifications](http://www.growlforwindows.com/gfw/) when there are build errors
- Support for other file formats - `.sass`, `.iced`, etc.


## System requirements

### Linux

Awe is developed and tested on Linux. It should run on Mac OS X too, but it hasn't been tested. It won't work on Windows because it uses symlinks.

### Node.js & npm

[Node.js](http://nodejs.org/) and [npm](https://www.npmjs.org/) must be installed. Awe is tested on Node.js 0.10, and may not work on older versions.

To check they're installed, run:

```bash
$ node --version
$ npm --version
```

#### Installing Node.js on Debian

On Debian Wheezy, Node.js is only available in [Backports](http://backports.debian.org/), but you will need to add that as a source:

```bash
$ sudo vim /etc/apt/sources.list
```

Add this line:

```
deb     http://ftp.uk.debian.org/debian/ wheezy-backports main contrib non-free
```

Then run the following to install it:

```bash
$ sudo apt-get update
$ sudo apt-get install curl nodejs nodejs-legacy
$ curl https://www.npmjs.org/install.sh | sudo sh
```

### Ruby & Bundler

You must also have [Ruby](https://www.ruby-lang.org/) and [Bundler](http://bundler.io/) installed - they are required to run [Compass](http://compass-style.org/), Sass files to CSS.

Since Awe is installed system-wide, they also need to be installed system-wide - i.e. not using [RVM](https://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv).

To check they're installed, run:

```bash
$ ruby --version
$ bundle --version
```

(Compass itself will be installed by Awe, so it does not need to be installed manually.)

#### Installing Ruby on Debian

```bash
$ sudo apt-get install ruby ruby-dev
$ sudo gem install bundler
```

### Bower (optional)

You may also install [Bower](http://bower.io/) for managing third-party assets:

```bash
sudo npm install -g bower
```

To check it's installed, run:

```bash
$ bower --version
```


## Installation

Simply install Awe using npm:

```bash
$ sudo npm install -g awe
```

This will install the Awe package globally, including the `awe` executable, and also download the Node.js and Ruby dependencies.

To check it's installed, run:

```bash
$ awe --version
```

### Installing a specific version

To install a specific version, use the `awe@<version>` syntax of npm, for example:

```bash
$ sudo npm install -g awe@1.0.0
```

To see a list of all available versions, see the [changelog](CHANGELOG.md)

### Upgrading

Because Awe is installed globally, you only need to upgrade it once per machine, not separately for each project. Every effort will be made to ensure backwards compatibility, though you should check the [changelog](CHANGELOG.md) to see what has changed.

#### Checking for updates

```bash
$ npm outdated -g awe
```

If Awe is up to date, only the headings will be displayed:

```
Package  Current  Wanted  Latest  Location
```

If there is a newer version, the currently installed version and latest version number will be displayed:

```
Package  Current  Wanted  Latest  Location
awe        1.0.0   1.1.0   1.1.0  /usr/lib > awe
```

#### Upgrading to the latest version

```bash
$ sudo npm update -g awe
```

#### Upgrading to a specific version

To upgrade (or downgrade) to a specific version, use `install` instead:

```bash
$ sudo npm install -g awe@1.0.0
```

### Uninstall

To remove Awe from your machine, simply uninstall it with npm:

```bash
$ sudo npm uninstall -g awe
```

This will also delete the Node.js and Ruby dependencies that were downloaded automatically during installation (e.g. CoffeeScript, Sass, Compass). It will not remove any project files (configuration, cache files or compiled assets).


## Getting started

### Create your source directory

First, create a directory for your source files. Let's say you're making a WordPress theme, so you would create a subdirectory named `src/` in your theme:

```bash
$ mkdir www/wp-content/themes/mytheme/src/
```

**Tip:** If you prefer, you can keep the `src/` directory outside the document root - e.g. `app/assets/` in Laravel.

### Configuration

Next, add the following to [`awe.yaml`](#configuration-file-aweyaml), altering the paths as necessary:

```yaml
assets:
    src:  www/wp-content/themes/mytheme/src/
    dest: www/wp-content/themes/mytheme/build/
```

**Note:** The `build/` directory **should not** be an existing directory as anything inside will be deleted.

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

Finally, run this command to generate the `build/` directory:

```bash
$ awe build
```

Or run this command to generate it and then wait for further changes:

```bash
$ awe watch
```

(Watch is the default command so you can also just run `awe` on its own.)

Since there are no special files in the list above, you will get exactly the same structure:

```
build/
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
build/
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
build/
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
build/
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
- `sprite_load_path` is set to `[<src dir>/img/, <src dir>/_sprites/]` - this is used for [sprite generation](#sprites)


## Sprites

Compass has the ability to take several small icons and combine them into a single image, then use that as a sprite in your CSS.

To do this, first create a directory inside `src/_sprites/` with the name of the sprite - e.g. `src/_sprites/navbar/`. Inside that directory create a PNG image for each icon. You can also have variants ending with `_hover`, `_active` and `_target` which map to `:hover`, `:active` and `:target` in the CSS. So, for example, you may have a directory structure like this:

```
src/
├── _sprites/
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
@import 'navbar/*.png';              // This path is relative to the _sprites/ directory
@include all-navbar-sprites;         // Replace 'navbar' with the directory name
```

This will generate a directory structure similar to the following:

```
build/
├── _generated/
│   └── navbar-s71af1c7425.png
└── sample.css
```

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

For further details (and more complex scenarios), please see the Compass [spriting documentation](http://compass-style.org/help/tutorials/spriting/). However, be aware that the Compass documentation refers to `images/`, whereas Awe uses either `_sprites/` or `img/`.


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
build/
└── combined.css
```

Simple as that!

**Note:** It is best to avoid mixing subdirectories and files, as some programs display all subdirectories first which may be confusing. If you do mix them, it's best to number them all to make it clear what order they are loaded in (e.g. `1-subdirectory/`, `2-file.js`, `3-another-directory/`).


## Import files

Another way to combine multiple files is to create an import file - this is a YAML file with the extension `.css.yaml` or `.js.yaml` containing a list of files to import. This is mostly useful for importing vendor files:

```
src/
└── vendor.js.yaml
vendor/
├── chosen.js
└── jquery.js
```

Where `vendor.js.yaml` contains:

```yaml
- ../vendor/jquery.js
- ../vendor/chosen.js
```

Will compile to:

```
build/
└── vendor.js
```

When importing files from Bower ([see below](#using-bower)) you can prefix the filename with `bower:` instead of providing a relative path:

```yaml
- bower: jquery/jquery.js
- bower: jquery-ui/ui/jquery-ui.js
```

## Using Bower

[Bower](http://bower.io/) is a package manager for third-party assets. It makes it easier to install and upgrade frontend dependencies such as jQuery and Bootstrap.

### Installing packages

Install the packages you need using Bower as normal - for example:

```bash
$ cd /path/to/repo
$ bower install jquery#1.x
```

This will create `bower_components/` directory in the project root (same directory as `awe.yaml`) containing the package and any dependencies.

For more details, please see the [Bower documentation](http://bower.io/).

### Import the files you need

Create a `.js.yaml` or `.css.yaml` [import file](#import-files) (e.g. `src/jquery.js.yaml`), for example:

```yaml
- bower: jquery/jquery.js
```

This will be compiled to `build/jquery.js`.

### Combining Bower and non-Bower files

You can easily combine Bower files with custom files, as described above. For example:

```
src/
├── app.css/
│   ├── 1-import.css.yaml   ==>   - bower: jquery-ui/themes/smoothness/jquery-ui.css
│   └── 2-custom.scss
└── app.js/
    ├── 1-import.js.yaml    ==>   - bower: jquery/jquery.js
    │                             - bower: jquery-ui/ui/jquery-ui.js
    └── 2-custom.coffee
```

Will result in:

```
build/
├── _bower/  ->  ..../bower_components/
├── app.css
└── app.js
```

(`->` indicates a symlink.)

The URLs from `jquery-ui.css` (now in `app.css`) will automatically be rewritten to `url(_bower/jquery-ui/themes/smoothness/<filename>)`.

### Custom Bower path

If the Bower components are installed somewhere other than `bower_components/` (relative to `awe.yaml`) you can specify a custom location in `awe.yaml`:

```yaml
theme:
    src:   www/wp-content/themes/mytheme/src/
    dest:  www/wp-content/themes/mytheme/build/
    bower: www/wp-content/themes/mytheme/bower_components/
```


## Configuration file (`awe.yaml`)

Each project requires a single config file, `awe.yaml`, in the root directory.

### About the YAML format

The file is in YAML (v1.2) format. This is similar in purpose to JSON, but easier to read and write.

Here is an example config file:

```yaml
theme:
    # This is a comment
    src:  www/wp-content/themes/mytheme/src/
    dest: www/wp-content/themes/mytheme/build/
```

Note how indentation is used to determine the structure, similar to Python and CoffeeScript, and strings do not need to be quoted. It also supports comments, unlike JSON. The equivalent JSON file is:

```json
{
    "theme": {
        "//":   "This is a trick to add a comment! http://stackoverflow.com/a/244858/167815",
        "src":  "www/wp-content/themes/mytheme/src/",
        "dest": "www/wp-content/themes/mytheme/build/"
    }
}
```

You shouldn't need to know any more than this to configure Awe, but if you would like to learn more about YAML, please see [Wikipedia](http://en.wikipedia.org/wiki/YAML) or the [official YAML website](http://www.yaml.org/).

### Creating `awe.yaml`

An [example config file](templates/awe.yaml) can be created by running `awe init` from the root directory of a project:

```bash
$ cd /path/to/repo
$ awe init
```

Then simply open `awe.yaml` in your preferred text editor to customise it as needed.

Alternatively you can create a config file by hand, or copy one from another project.


## Command-line interface (`awe`)

Awe installs a single executable - `awe`. It accepts several subcommands, such as `awe build` - similar to `git`. Some commands can be run at any time, while others require you to be inside a project that has an [`awe.yaml` config file](#configuration-file-aweyaml).

### Global commands

These commands can be run from any directory:

```bash
# Create an awe.yaml file in the current directory
$ awe init

# Display help
$ awe help

# Display the current version number
$ awe version
```

### Project commands

These commands can only be run from a directory containing an `awe.yaml` config file (or any subdirectory):

```bash
# Build once
$ awe build

# Build then wait for further changes
$ awe watch
$ awe          # 'watch' is the default command
```


## Cache files

Awe will create a hidden directory named `.awe` inside each project, which is used to hold cache files and speed it up.

This directory will automatically be ignored by Git. If you are using another version control system you may need to exclude it manually, and you may want to configure your editor / IDE to hide it. For example, in Sublime Text you would go to Project > Edit Project and add a `folder_exclude_patterns` section:

```json
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
```


## Quick reference

### Configuration

```yaml
groupname:                          # required (a-z, 0-9 only)
    src:          path/to/src/      # required
    dest:         path/to/build/    # required
    autoprefixer: false             # optional (default: true)
    bower:        false             # optional (default: bower_components/)
    sourcemaps:   false             # optional (default: true)
    warning file: false             # optional (default: true)

anothergroup:                       # optional
    ...
```

### Command-line interface

```bash
# Build once
$ awe build

# Build every time a source file is modified
$ awe watch

# Watch is the default if no command is given
$ awe
```

### Directory structure

```
SOURCE                    DESTINATION                 NOTES
───────────────────────── ─────────────────────────── ───────────────────────────────────────
src/                      build/
│                         │
│                         ├── _bower/                 Symlink to bower_components/ directory
│                         │
│                         ├── _generated/             Compass─generated files (e.g. sprites)
│                         │   └── nav-s71af1c74.png
│                         │
├── _partials/            │                           Ignored (starts with _)
│   └── reset.scss        │
│                         │
│                         ├── _src/                   Symlink to src/ (for source maps)
│                         │
├── _sprites/             │                           Compass sprite source images
│   └── nav/              │
│       ├── edit.png      │
│       └── save.png      │
│                         │
├── _vars.scss            │                           Ignored (starts with _)
│                         │
├── combined.css/         ├── combined.css            Combined (ends with .css)
│   ├── 1.css             │
│   ├── 2.scss            │
│   └── 3-subdirectory/   │
│       ├── A.css         │
│       └── B.scss        │
│                         │
├── combined.js/          ├── combined.js             Combined (ends with .js)
│   ├── 1.js              │
│   ├── 2.coffee          │
│   └── 3-subdirectory/   │
│       ├── A.js          │
│       └── B.coffee      │
│                         │
├── img/                  ├── img/                    Images are copied unaltered
│   └── logo.png          │   └── logo.png
│                         │
├── sample1.css           ├── sample1.css             CSS file is copied (URLs rewritten)
├── sample2.scss          ├── sample2.css             Sass file is compiled
├── sample3.js            ├── sample3.js              JavaScript file is copied
├── sample4.coffee        ├── sample4.js              CoffeeScript file is compiled
│                         │
└── subdirectory/         └── subdirectory/           Directory structure is preserved
    ├── A.css                 ├── A.css
    ├── B.scss                ├── B.css
    ├── C.js                  ├── C.js
    └── D.coffee              └── D.js
```


## Contributing to Awe

See the [CONTRIBUTING](CONTRIBUTING.md) file for details of how to contribute to Awe.


## Changelog

See the [CHANGELOG](CHANGELOG.md) for a list of changes and upgrade instructions.


## License

Copyright © 2014 Dave James Miller. Released under [MIT License](LICENSE.txt).
