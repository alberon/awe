# Writing documentation for Awe

The documentation is written in [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown), designed to be viewed directly in the GitHub interface. This makes it easy to find the documentation for the currently installed version, or any other version, simply by switching branches/tags.

GitHub makes it easy for anyone to edit Markdown files in the browser, preview the output, and submit them as pull requests. Please feel free to do so if you think there's anything that can be improved.

## Conventions

Please respect the following conventions when editing the Awe documentation:

- Write paragraphs on a single line, not with new lines to limit the line length - this makes it easier to edit text later
- Use `- hyphens` for lists instead of `* asterisks` - they're easier to type
- Use `# hash marks` for headings instead of underlining them - ditto

## Viewing documentation locally

When editing a lot of documentation, it's helpful to be able to preview it before you commit and upload your changes. For this I strongly recommend using [Grip - GitHub Readme Instant Preview](https://github.com/joeyespo/grip).

### Installing Grip

At the time of writing (27 Jul 2014), there is [a bug](https://github.com/joeyespo/grip/issues/38) in the released version (2.0.1) that prevents it running without `sudo`, so I suggest installing the latest development version instead:

```bash
$ sudo pip install git+git://github.com/joeyespo/grip@master --upgrade
```

Alternatively you can install the latest released version:

```bash
$ sudo pip install grip --upgrade
```

### Configuring Grip

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

### Running Grip

To start the Grip server, simply run it from the Awe source directory:

```bash
$ cd /path/to/awe
$ grip
```

Then open `http://<hostname>:5000/` in your web browser.

To stop the Grip server, type `Ctrl-C`.

### Troubleshooting: Address already in use

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
