# Awe configuration

Each project requires a single config file, `awe.yaml`, in the root directory.

## About the YAML format

The file is in YAML (v1.2) format. This is similar in purpose to JSON, but easier to read and write.

Here is an example config file:

```yaml
assets:
    theme:
        # This is a comment
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/dist/
        bower: true
```

Note how indentation is used to determine the structure, similar to Python and CoffeeScript, and strings do not need to be quoted. It also supports comments, unlike JSON. The equivalent JSON file is:

```json
{
    "assets": {
        "theme": {
            "//": "This is a hacky way to add a comment!! http://stackoverflow.com/a/244858/167815",
            "src": "www/wp-content/themes/mytheme/src/",
            "dest": "www/wp-content/themes/mytheme/dist/",
            "bower": true
        }
    }
}
```

You shouldn't need to know any more than this to configure Awe, but if you would like to learn more about YAML, please see [Wikipedia](http://en.wikipedia.org/wiki/YAML) or the [official YAML website](http://www.yaml.org/).

## Creating `awe.yaml`

An [example config file](../templates/awe.yaml) can be created by running `awe init` from the root directory of a project:

```bash
$ cd /path/to/repo
$ awe init
```

Then simply open `awe.yaml` in your preferred text editor to customise it as needed.

Alternatively you can create a config file by hand, or copy one from another project - there's nothing special about `awe init`.

## Config file structure

The file is designed to be split up into several sections, such as `assets`, `environments`, `config`, `mysql`, `crontab`, etc. to support additional functionality in the future while maintaining backwards compatibility. At this time, only `assets` is supported.

For details of the options supported, please continue to rest of the [documentation](../README.md#documentation).
