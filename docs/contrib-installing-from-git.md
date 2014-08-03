# Installing Awe from Git

## 1. Check system requirements

First make sure you have installed the [system requirements](start-requirements.md) - particularly Node.js, npm, Ruby & Bundler.

## 2. Download source code

Next, you need to obtain a copy of the Awe source code, if you haven't already. If you are planning to make changes, it is easier to fork the [Awe repository on GitHub](https://github.com/davejamesmiller/awe) first - then use your own username below.

You can install Awe into any location - `~/awe/` would be a logical choice.

```bash
$ cd ~
$ git clone git@github.com:davejamesmiller/awe.git
```

## 3. Install dependencies

```bash
$ cd awe
$ npm install
```

This will:

- Install Node.js dependencies using npm
- Install Ruby dependencies using Bundler
- Compile the source files (CoffeeScript)
- Run the test suite

At this point it should be possible to run Awe by specifying the path to the executable:

```bash
$ ~/awe/bin/awe --version
```

## 4. Make it the default version (optional)

If you would like to run `awe` directly, instead of using the full path, you can use **one** of the following options:

### 4a. For yourself only (using `alias`)

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

### 4b. For yourself only (using `$PATH`)

Alternatively, you can add it to your system path:

```bash
$ export PATH="$HOME/awe/bin:$PATH"
```

This is a more accurate test of functionality, and may be necessary if you are running Awe from a script, but is a little harder to remove later.

Again you can make this change permanent by adding it to your shell config script:

```bash
$ echo 'export PATH="$HOME/awe/bin:$PATH"' >> ~/.bashrc
```

### 4c. System-wide

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
