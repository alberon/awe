# Installing Awe

First make sure you have installed the [requirements](start-requirements.md) - particularly Node.js, npm, Ruby & Bundler.

Then simply install Awe using npm:

```bash
$ sudo npm install -g awe
```

This will install the Awe package globally, including the `awe` executable, and also download the Node.js and Ruby dependencies.

To check it's installed, run:

```bash
$ awe --version
```

## Installing a specific version

To install a specific version, use the `awe@<version>` syntax of npm, for example:

```bash
$ sudo npm install -g awe@1.0.0
```

To install a development version instead, see [Installing from Git](contrib-installing-from-git.md).
