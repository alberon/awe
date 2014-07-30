# Awe command-line summary

## Global commands

*These commands can be run from any directory.*

Create an `awe.yaml` file in the current directory:

```bash
$ awe init
```

Display help:

```bash
$ awe help
```

Display the current version:

```bash
$ awe version
```

## Project commands

*These commands can only be run from a directory containing an `awe.yaml` [config file](configuration.md) (or any subdirectory).*

Build [assets](assets.md):

```bash
$ awe build
```

Build assets, then watch for any changes and rebuild automatically:

```bash
$ awe watch
```
