# Awe (v0.1.0 - Beta release)

## Introduction

Awe simplifies the building and maintenance of websites / web apps, by handling the compilation of **assets**. (In the future it will also handle **deployment** to remote live/staging servers, and related functionality such as **configuration management**.)

Awe is designed for web/software development agencies and freelancers managing many different websites, so:

- It relies on convention rather than configuration as much as possible, to ensure consistency and simplicity
- It is installed system-wide, not per-project, to avoid the maintenance overhead of installing and upgrading it multiple times
- All features are optional, so it can be added to existing projects without major changes

Unlike the popular tools [Grunt](http://gruntjs.com/) and [Gulp](http://gulpjs.com/), Awe is not designed to be a general purpose task runner or build tool - so it won't suit everyone. However, it should be easier to configure.


## Features

### Assets

- Compile [CoffeeScript](http://coffeescript.org/) (`.coffee`) files to JavaScript
- Compile [Sass](http://sass-lang.com/)/[Compass](http://compass-style.org/) (`.scss`) files to CSS
- [Autoprefix](https://github.com/ai/autoprefixer) CSS rules for easier cross-browser compatibility
- Combine multiple JavaScript/CSS source files into a single file
- Rewrite relative URLs in CSS files that are combined
- Rewrite URLs in symlinked CSS files (e.g. packages installed with [Bower](http://bower.io/))
- Generate [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/) for easier debugging
- Watch for changes to source files and rebuild automatically

### Miscellaneous

- Simple YAML configuration
- Detailed documentation
- Unit tests to ensure backwards-compatibility

### Coming soon

- Minify JavaScript & CSS files
- Optimise images
- [Automatically reload](http://livereload.com/) your web browser when assets are rebuilt
- Display Growl notifications when there are build errors
- Display an interactive menu for less technical frontend developers
- Deploy to a live/staging server


## System requirements

### Linux

Awe is developed and tested on Linux. (It will probably run on Mac OS X too, but it hasn't been tested.)

It will probably not work on Windows because it uses symlinks. (It may be possible to get it working under Cygwin, but this also hasn't been tested. I may reconsider this in the future if there is demand for it.)

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

You must also have [Ruby](https://www.ruby-lang.org/) and [Bundler](http://bundler.io/) installed, because [Compass](http://compass-style.org/) is used to compile Sass to CSS. Since Awe is designed to be installed system-wide, they also need to be installed system-wide - i.e. not using [RVM](https://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv).

To check they're installed, run:

```bash
$ ruby --version
$ bundle --version
```

**Note:** Compass itself will be installed automatically when you install Awe, so it does not need to be installed manually. It is installed using Bundler, so it won't conflict with any existing version that may be installed, nor will it install the `compass` executable.

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

This isn't required, however, because you can choose to install them manually.


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

To see a list of all available versions, see the [changelog](#changelog)

### Installing a development version from Git

#### Download source code

Obtain a copy of the Awe source code, if you haven't already. If you are planning to make changes, it is easier to fork the [Awe repository on GitHub](https://github.com/davejamesmiller/awe) first - then use your own username below.

You can install Awe into any location - `~/awe/` would be a logical choice.

```bash
$ cd ~
$ git clone git@github.com:davejamesmiller/awe.git
```

#### Install dependencies

```bash
$ cd awe
$ npm install
```

This will:

- Install Node.js dependencies using npm
- Install Ruby dependencies using Bundler
- Compile the source files (from [IcedCoffeeScript](http://maxtaco.github.io/coffee-script/) to JavaScript)
- Run the test suite ([Mocha](http://visionmedia.github.io/mocha/))

At this point it should be possible to run Awe by specifying the path to the executable:

```bash
$ ~/awe/bin/awe --version
```

#### Make it the default version (optional)

If you would like to run `awe` directly, instead of using the full path, you can use **one** of the following options:

##### a. For yourself only (using `alias`)

```bash
$ alias awe="$HOME/awe/bin"
```

To remove it later (revert to the globally installed version):

```bash
$ unalias awe
```

To make this change permanent, add it to your shell config file - for example:

```bash
$ echo 'alias awe="$HOME/awe/bin"' >> ~/.bashrc
```

##### b. For yourself only (using `$PATH`)

Alternatively, you can add it to your system path:

```bash
$ export PATH="$HOME/awe/bin:$PATH"
```

This is a more accurate test of functionality, and may be necessary if you are running Awe from a script, but is a little harder to remove later.

Again you can make this change permanent by adding it to your shell config script:

```bash
$ echo 'export PATH="$HOME/awe/bin:$PATH"' >> ~/.bashrc
```

##### c. System-wide

Or, finally, you can install it system-wide using npm. This has the advantage of allowing you to test the manual page (`man awe`), but otherwise is not recommended.

**Warning:** It's probably best to avoid using this method on a multi-user system - only do it on your own development machine. You will need to make sure the directory is world-readable, else other users won't be able to use Awe. (You can check if it works by running `sudo -u nobody awe --version`.)

```bash
sudo npm uninstall -g awe  # Remove currently installed version, if any
sudo npm link
```

**Note:** You can ignore the following warning messages, as long as you ran `npm install` above:

```
npm WARN cannot run in wd awe@1.0.0 bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --deployment --without=development
npm WARN cannot run in wd awe@1.0.0 grunt build test
```

To remove it later:

```bash
sudo npm uninstall -g awe
```

### Upgrading

Because Awe is installed globally, you only need to upgrade it once per machine, not separately for each project. Every effort will be made to ensure backwards compatibility, though you should check the [changelog](#changelog) to see what has changed.

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

Or if you installed from Git and want the latest development version:

```bash
$ git pull origin master
$ npm install
```

#### Upgrading to a specific version

To upgrade (or downgrade) to a specific version, use `install` instead:

```bash
$ sudo npm install -g awe@1.0.0
```

Or if you installed from Git just checkout a specific tag:

```bash
$ git fetch origin
$ git checkout v1.0.0
$ npm install
```

### Uninstall

To remove Awe from your machine, simply uninstall it with npm:

```bash
$ sudo npm uninstall -g awe
```

This will also delete the Node.js and Ruby dependencies that were downloaded automatically during installation (e.g. CoffeeScript, Sass, Compass). It will not remove any project files (configuration, cache files or compiled assets).

If you installed it using Git, see the notes in the installation instructions above to remove the links, then simply delete the directory it is installed in.


## Configuration file (`awe.yaml`)

Each project requires a single config file, `awe.yaml`, in the root directory.

### About the YAML format

The file is in YAML (v1.2) format. This is similar in purpose to JSON, but easier to read and write.

Here is an example config file:

```yaml
assets:
    theme:
        # This is a comment
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/build/
        bower: true
```

Note how indentation is used to determine the structure, similar to Python and CoffeeScript, and strings do not need to be quoted. It also supports comments, unlike JSON. The equivalent JSON file is:

```json
{
    "assets": {
        "theme": {
            "//": "This is a hacky way to add a comment!! http://stackoverflow.com/a/244858/167815",
            "src": "www/wp-content/themes/mytheme/src/",
            "dest": "www/wp-content/themes/mytheme/build/",
            "bower": true
        }
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

Alternatively you can create a config file by hand, or copy one from another project - there's nothing special about `awe init`.

### Config file structure

The file is designed to be split up into several sections, such as `assets`, `environments`, `config`, `mysql`, `crontab`, etc. to support additional functionality in the future while maintaining backwards compatibility. At this time, only `assets` is supported.

For details of the options supported, please continue to rest of the documentation, below.


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
$ awe build
$ awe watch
```

For details of these commands, please continue to rest of the documentation, below.


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


## Assets

### Initial setup

#### Create your source directory

First, create a directory for your source files. Let's say you're making a WordPress theme, so you would create a subdirectory named `src/` in your theme:

```bash
$ mkdir www/wp-content/themes/mytheme/src/
```

**Tip:** If you prefer, you can keep the `src/` directory outside the document root - e.g. `app/assets/` in Laravel.

#### Configuration

Next, add the following to [`awe.yaml`](#configuration-file-aweyaml), altering the paths as necessary:

```yaml
assets:
    theme:
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/build/
```

**Note:** The `build/` directory **should not** be an existing directory as anything inside will be deleted.

#### Create your source files

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

#### Run the `build` command

Finally, run this command to generate the `build/` directory:

```bash
$ awe build
```

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

### CoffeeScript

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

### Sass

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

### Ignoring partials

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

### Compass

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

#### Compass configuration

You may need to be aware of the following configuration options that Awe uses:

- `images_path` is set to `<src dir>/img/` - this is used by [`image-url()`](http://compass-style.org/reference/compass/helpers/urls/), [`inline-image()`](http://compass-style.org/reference/compass/helpers/inline-data/) and related functions
- `fonts_path` is set to `<src dir>/fonts/` - this is used by [`font-url()`](http://compass-style.org/reference/compass/helpers/urls/), [`inline-font-files()`](http://compass-style.org/reference/compass/helpers/inline-data/) and related functions

### Sprites

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

### Combining files

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

### Bower

[Bower](http://bower.io/) is a package manager for third-party assets. It makes it easier to install and upgrade frontend dependencies such as jQuery and Bootstrap.

#### Installing packages

Install the packages you need using Bower, for example:

```bash
$ cd /path/to/repo
$ bower install jquery#1.x
```

This will create `bower_components/` directory in the project root (same directory as `awe.yaml`) containing package and any dependencies.

For more details, please see the [Bower documentation](http://bower.io/).

#### Configure Awe

To enable Bower support in Awe, add `bower: true` to the asset group in the config file (`awe.yaml`) - for example:

```yaml
assets:
    theme:
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/build/
        bower: true
```

#### Create symlinks to the files

Finally, create a symlink from the `src/` directory to any file you want available. For example:

```bash
$ cd www/wp-content/themes/mytheme/src/
$ ln -s ../../../../../bower_components/jquery/dist/jquery.js jquery.js
```

**Note:** You must use a **relative** path when creating the symlink, else it will break when installed in a different location.

You can do the same with CSS files - Awe will automatically create a symlink and rewrite any relative URLs to images.

#### Combining Bower and non-Bower files

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
build/
├── _bower/     ->  ..../bower_components/
├── app.css
└── app.js
```

The URLs from `jquery-ui.css` (now in `app.css`) will automatically be rewritten to the form `url(_bower/jquery-ui/..../<filename>.png)`.

### Quick reference

#### Configuration

```yaml
assets:

    groupname:                  # required (a-z, 0-9 only)
        src: path/to/src/       # required
        dest: path/to/build/    # required
        bower: true             # optional (default: false)

    anothergroup:               # optional
        ...
```

#### Command-line interface

```bash
# Build once
$ awe build

# Build every time a source file is modified
$ awe watch
```

#### Directory structure

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

### Grunt tasks

The following tasks are used when developing Awe:

```bash
# Build everything and then watch for further changes
$ grunt         # 'watch' is the default task
$ grunt watch

# Build `lib/` from `lib-src/` (IcedCoffeeScript to JavaScript)
$ grunt lib

# Build `man/` from `man-src/` (Markdown to Man pages)
$ grunt man

# Build everything
$ grunt build

# Run all unit tests
$ grunt test

# Run unit tests in `test/<suite>.coffee` only
$ grunt test <suite>

# Update the Ruby gems to the latest version
$ grunt bundle
```

#### Installing Grunt

If you don't already have the Grunt CLI installed, you can install it with npm:

```bash
$ sudo npm install -g grunt-cli
```

### Unit tests

If you are running `grunt watch`, unit tests (`tests/*.coffee`) will be run automatically when you modify the corresponding source file (`lib-src/*.iced`).

Please ensure that every important function and bug fix has corresponding unit tests.

### Writing documentation

The documentation is written in [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown), designed to be viewed directly in the GitHub interface. This makes it easy to find the documentation for the currently installed version, or any other version, simply by switching branches/tags.

GitHub makes it easy for anyone to edit Markdown files in the browser, preview the output, and submit them as pull requests. Please feel free to do so if you think there's anything that can be improved.

#### Conventions

Please respect the following conventions when editing the Awe documentation:

- Write paragraphs on a single line, not with new lines to limit the line length - this makes it easier to edit text later
- Use `- hyphens` for lists instead of `* asterisks` - they're easier to type
- Use `# hash marks` for headings instead of underlining them - ditto

#### Viewing documentation locally

When editing a lot of documentation, it's helpful to be able to preview it before you commit and upload your changes. For this I strongly recommend using [Grip - GitHub Readme Instant Preview](https://github.com/joeyespo/grip).

##### Installing Grip

```bash
$ sudo pip install grip --upgrade
```

##### Configuring Grip

By default Grip will only be accessible on `localhost`, not over the network. If you're using a separate development server or virtual machine, you will need to configure it to allow access on all network interfaces:

```bash
$ mkdir ~/.grip
$ echo "HOST = '0.0.0.0'" >> ~/.grip/settings.py
```

If you find yourself hitting the rate limit (60 requests per hour), you will need to [generate a personal access token](https://github.com/settings/tokens/new?scopes=) and enable authentication:

```bash
$ echo "USERNAME = '<username>'" >> ~/.grip/settings.py
$ echo "PASSWORD = '<token>'" >> ~/.grip/settings.py
```

**Tip:** For security, don't enter your password in `settings.py` - always use an access token. (Also, you should enable [Two-Factor Authentication](https://help.github.com/articles/about-two-factor-authentication) on your account.)

For more details, please see the [Grip readme](https://github.com/joeyespo/grip).

##### Running Grip

To start the Grip server, simply run it from the Awe source directory:

```bash
$ cd /path/to/awe
$ grip
```

Then open `http://<hostname>:5000/` in your web browser.

To stop the Grip server, type `Ctrl-C`.

##### Troubleshooting: Address already in use

If you get this error message:

```
Traceback (most recent call last):
  ...
socket.error: [Errno 98] Address already in use
```

This means port `5000` is already in use - either by another instance of Grip or by another process. You can specify a different port number instead:

```bash
$ grip 5001
```

Then open `http://<hostname>:5001/` in your web browser instead.

### Releasing new versions of Awe

#### Prepare

- Run `git pull` to ensure all changes are merged
- Test with `grunt test`
- Check the documentation is up-to-date
- Update the changelog

#### Release

- Run `npm version X.Y.Z` to update `package.json`
- Run `git push && git push --tags` to upload the code and tag to GitHub
- Run `npm publish` to upload to npm

#### Finalise

- Run `sudo npm update -g awe` to upgrade Awe on your own machine(s)


## Changelog

This project uses [Semantic Versioning](http://semver.org/).

### 0.1.0 - Unreleased

- `awe build`
  - Add support for Autoprefixer
  - ...

### 0.0.5 - 7 Sep 2014

- `awe build`
  - Don't attempt to rewrite URLs inside CSS comments
- `awe watch`
  - Bug fix - Prevent crash when multiple files are changed at once (by debouncing and queuing)
  - Use `fs.watch()` instead of `fs.watchFile()` - triggers much faster

### 0.0.4 - 4 Aug 2014

- Add more info to `package.json` to display on the [npm website](https://www.npmjs.org/package/awe)

### 0.0.3 - 4 Aug 2014

- `awe build`
  - Bug fix - `rimraf` was in `devDependencies` not `dependencies`

### 0.0.2 - 4 Aug 2014

- `awe build` (new)
  - Compile `.scss` and `.coffee` files
  - Combine `.js` and `.css` directories to a single output file
  - Copy all other files unchanged
- `awe help` (new)
  - Display basic help
- `awe init` (new)
  - Create awe.yaml in the current directory
- `awe version` (new)
  - Display the Awe version number
- `awe watch` (new)
  - Watch for changes and rebuild automatically

### 0.0.1 - 17 May 2014

- Proof of concept / placeholder to register the name on [npm](https://www.npmjs.org/package/awe)


## License

Copyright © 2014 Dave James Miller. Released under [MIT License](LICENSE.txt).
