# Installing Awe from Git

## 1. Install dependencies

Make sure you have the dependencies installed, as described in [Installation](installation.md).

## 2. Download source code

Obtain a copy of the Awe source code, for example:

```bash
$ cd ~
$ git clone git@github.com:davejamesmiller/awe.git
```

**Note:** If you're planning to make changes, it would be easiest to fork the repository on GitHub first - then use your own username above.

## 3. Install Node and Ruby packages

```bash
$ cd awe
$ npm install
```

At this point it should be possible to run Awe by specifying the path to the executable:

```bash
$ ~/awe/bin/awe version
```

## 4. Make it the default version (optional)

### 4a. For yourself only (using `alias`)

```bash
$ alias awe="$HOME/awe/bin"
```

This will allow you to run `awe` directly, instead of using the full path:

```bash
$ awe version
```

To remove it later:

```bash
unalias awe
```

(And remove it from `~/.bashrc` if necessary.)

To make this change permanent, add it to your shell config script - for example:

```bash
echo 'alias awe="$HOME/awe/bin"' >> ~/.bashrc
```

### 4b. For yourself only (using `$PATH`)

Alternatively, you can add it to your system path:

```bash
$ export PATH="$HOME/awe/bin:$PATH"
```

Again you can make this change permanent by adding it to your shell config script:

```bash
echo 'export PATH="$HOME/awe/bin:$PATH"' >> ~/.bashrc
```

### 4c. System-wide

Or, finally, you can install it system-wide using npm. This has the advantage of allowing you to test the manual page (`man awe`), but otherwise is not recommended.

```bash
sudo npm uninstall -g awe  # Remove currently installed version, if any
sudo npm link
```

You can ignore the following warning messages as long as you ran `npm install` above:

```
npm WARN cannot run in wd awe@1.0.0 bundle install --path=ruby_bundle --binstubs=ruby_bundle/bin --deployment --without=development
npm WARN cannot run in wd awe@1.0.0 grunt build test
```

**Note:** If you want other users to be able to run Awe, you will need to make the directory world-readable. In general it's probably best to avoid using this method on a multi-user system - only do it on your own development machine. You can check if it works by running `sudo -u nobody awe version`.

To remove it later:

```bash
sudo npm uninstall -g awe
```
