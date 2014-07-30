# Awe configuration summary

Awe is configured by adding an `awe.yaml` file in the root of a project.

The file is in YAML (v1.2) format. This is similar in purpose to JSON, but easier to read and write. (Please see [Wikipedia](http://en.wikipedia.org/wiki/YAML) or the [official YAML website](http://www.yaml.org/) if you would like to learn more.)

## Generating `awe.yaml`

A config file can be generated automatically by running `awe init` from the project root directory:

```bash
$ cd /path/to/repo
$ awe init
```

Then simply open `awe.yaml` in your preferred text editor to customise it as needed.

Alternatively you can create the config file by hand, or copy it from another project.

## Config file structure

Here is an example config file:

```yaml
assets:
    theme:
        src: www/wp-content/themes/mytheme/src/
        dest: www/wp-content/themes/mytheme/dist/
```

The file is designed to be split up into several sections, such as `assets`, `environments`, `config`, `mysql`, `crontab`, etc. At this time, only `assets` is supported.

## More details

For more details, please see the relevant section of the documentation:

- [Assets](assets.md)
