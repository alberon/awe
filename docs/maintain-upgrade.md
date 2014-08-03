## Upgrading Awe

Because Awe is installed globally, you only need to upgrade it once per machine, not separately for each project. Every effort will be made to ensure backwards compatibility, though you should check the [../CHANGELOG.md](changelog) to see what has changed.

## Checking for updates

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

## Upgrading to the latest version

```bash
$ sudo npm update -g awe
```

## Upgrading to a specific version

To upgrade (or downgrade) to a specific version, use `install` instead:

```bash
$ sudo npm install -g awe@1.0.0
```
