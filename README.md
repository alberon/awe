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
