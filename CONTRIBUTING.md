# Contributing to Awe

To submit an improvement to the documentation, simply [edit the file using GitHub](https://github.com/davejamesmiller/awe/edit/master/README.md). This will automatically be turned into a pull request.

If you want to submit a bug fix, the information below may help you to get started. Make your changes in a new branch, based on the `develop` branch, then simply open a [pull request](https://github.com/davejamesmiller/awe/pulls) on GitHub.

If you want to submit a new feature, you may want to open an [issue](https://github.com/davejamesmiller/awe/issues) to discuss the idea first, to make sure it will be accepted. (Or you can go ahead and develop it first if you prefer!)

## Installing from Git

### Check system requirements

First make sure your system meets the [system requirements](README.md#system-requirements).

### Download source code

Obtain a copy of the Awe source code, if you haven't already. If you are planning to make changes, it is easier to [fork the Awe repository on GitHub](https://github.com/davejamesmiller/awe/fork) first - then use your own username below.

You can install Awe into any location - `~/awe/` would be a logical choice.

```bash
$ cd ~
$ git clone git@github.com:davejamesmiller/awe.git
```

### Install dependencies

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

### Make it the default version (optional)

If you would like to run `awe` directly, instead of using the full path, you can use **one** of the following options:

#### a. For yourself only (using `alias`)

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

#### b. For yourself only (using `$PATH`)

Alternatively, you can add it to your system path:

```bash
$ export PATH="$HOME/awe/bin:$PATH"
```

This is perhaps a more accurate test of functionality, and may be necessary if you are running Awe from a script.

Again you can make this change permanent by adding it to your shell config script:

```bash
$ echo 'export PATH="$HOME/awe/bin:$PATH"' >> ~/.bashrc
```

#### c. System-wide

Or, finally, you can install it system-wide using npm. This has the advantage of allowing you to test the manual page (`man awe`) as well, but it's probably best to avoid this method on a multi-user system as it will replace any other versions that are installed.

```bash
sudo npm uninstall -g awe  # Remove currently installed version, if any
sudo npm link
```

You may get the following warning messages due to npm security restrictions - they can be ignored as long as you ran `npm install` above:

```
npm WARN cannot run in wd awe@1.0.0 bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --deployment --without=development
npm WARN cannot run in wd awe@1.0.0 grunt build test
```

To remove it later:

```bash
sudo npm uninstall -g awe
```

### Upgrading Awe from Git

```bash
$ cd awe
$ git pull
$ npm install
```

### Uninstalling

If you have made it the system-wide default version, remove it first:

```bash
sudo npm uninstall -g awe
```

Then simply delete the source directory.


## Grunt tasks

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

### Installing Grunt

If you don't already have the Grunt CLI installed, you can install it with npm:

```bash
$ sudo npm install -g grunt-cli
```


## Unit tests

Please ensure that every important function and bug fix has corresponding unit tests.

When you run `grunt watch`, every time you modify a source file (`lib-src/*.iced`) the corresponding unit tests (`tests/*.coffee`) will be run automatically. When you're finished, run `grunt test` to run all unit tests.


## Writing documentation

The documentation is written in [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown), designed to be viewed directly in the GitHub interface. This makes it easy to find the documentation for the currently installed version, or any other version, simply by switching branches/tags.

### Conventions

Please respect the following conventions when editing the Awe documentation:

- Write paragraphs on a single line, not with new lines to limit the line length - this makes it easier to edit text later
- Use `- hyphens` for lists instead of `* asterisks` - they're easier to type
- Use `# hash marks` for headings instead of underlining them - ditto

### Viewing documentation locally

When editing a lot of documentation, it's helpful to be able to preview it before you commit and upload your changes. For this I strongly recommend using [Grip - GitHub Readme Instant Preview](https://github.com/joeyespo/grip).

To install Grip run:

```bash
$ sudo pip install grip --upgrade
```

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

To start the Grip server, simply run it from the Awe source directory:

```bash
$ cd /path/to/awe
$ grip
```

Then open `http://<hostname>:5000/` in your web browser.

To stop the Grip server, type `Ctrl-C`.

#### Troubleshooting: Address already in use

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


## Releasing a new version

*This is a reference for me:*

### Prepare

- Run `git pull` to ensure all changes are merged
- Test with `grunt test`
- Check the documentation is up-to-date
- Update the changelog

### Release

- Run `npm version X.Y.Z` to update `package.json`
- Run `git push && git push --tags` to upload the code and tag to GitHub
- Run `npm publish` to upload to npm

### Finalise

- Run `sudo npm update -g awe` to upgrade Awe on your own machine(s)
