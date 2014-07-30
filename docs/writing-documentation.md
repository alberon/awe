# Writing documentation for Awe

The documentation is written in [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown), designed to be viewed directly in the GitHub interface. This makes it easy to find the documentation for the currently installed version, or any other version, simply by switching branches/tags.

## Previewing documentation with Grip

When writing documentation in Markdown, it's helpful to be able to preview it before you commit and upload it. For this I strongly recommend using [Grip - GitHub Readme Instant Preview](https://github.com/joeyespo/grip).

### Installing Grip

At the time of writing (27 Jul 2014), there is [a bug](https://github.com/joeyespo/grip/issues/38) in the released version (2.0.1) that prevents it running on Debian, so I suggest installing the latest development version instead:

```bash
sudo pip install git+git://github.com/joeyespo/grip@master --upgrade
```

By default Grip will only be accessible on `localhost`, not over the network. If you're using a separate development server or VM, you will need to configure it to allow access on all network interfaces:

```bash
mkdir ~/.grip
echo "HOST = '0.0.0.0'" >> ~/.grip/settings.py
```

### Running Grip

To run Grip:

```bash
cd /path/to/awe
grip
```

Then open `http://<hostname>:5000/` in your web browser.

To exit Grip, type `Ctrl-C`.

### Troubleshooting: Address already in use

If you get this error message:

```
Traceback (most recent call last):
  ...
socket.error: [Errno 98] Address already in use
```

This means port `5000` is already in use - either by another process, or by another instance of Grip. You can specify a different port number instead:

```bash
cd /path/to/awe
grip 5001
```

Then open `http://<hostname>:5001/` in your web browser instead.
