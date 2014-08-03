## Assets - Quick reference

### Configuration

```yaml
assets:

    groupname:                  # required (a-z, 0-9 only)
        src: path/to/src/       # required
        dest: path/to/dist/     # required
        bower: true             # optional (default: false)

    anothergroup:               # optional
        ...
```

## Command-line interface

```bash
# Build once
$ awe build

# Build every time a source file is modified
$ awe watch
```

### Directory structure

```
SOURCE                      DESTINATION                      NOTES
──────────────────────────  ───────────────────────────────  ───────────────────────────────────────
src/                        dist/
│                           │
│                           ├── _bower/                    < Symlink to bower_components/ directory
│                           │
│                           ├── _generated/                < Compass─generated files (e.g. sprites)
│                           │   └── icon-s71af1c7425.png
│                           │
├── _partials/              │                              < Directories starting with _ are ignored
│   └── reset.scss          │
│                           │
├── _vars.scss              │                              < Files starting with _ are ignored
│                           │
├── combined.css/           ├── combined.css               < .css directory: files are combined
│   ├── 1.css               │
│   ├── 2.scss              │
│   └── 3-subdirectory/     │
│       ├── A.css           │
│       └── B.scss          │
│                           │
├── combined.js/            ├── combined.js                < .js directory: files are combined
│   ├── 1.js                │
│   ├── 2.coffee            │
│   └── 3-subdirectory/     │
│       ├── A.js            │
│       └── B.coffee        │
│                           │
├── img/                    ├── img/                       < Images are copied unaltered
│   ├── icon/               │   ├── icon/                  < Use subdirectories for sprites
│   │   ├── icon1.png       │   │   ├── icon1.png
│   │   └── icon2.png       │   │   └── icon2.png
│   └── logo.png            │   └── logo.png
│                           │
├── sample1.css             ├── sample1.css                < CSS file is copied
├── sample2.scss            ├── sample2.css                < Sass file is compiled
├── sample3.js              ├── sample3.js                 < JavaScript file is copied
├── sample4.coffee          ├── sample4.js                 < CoffeeScript file is compiled
│                           │
└── subdirectory/           └── subdirectory/              < Directory structure is preserved
    ├── A.css                   ├── A.css
    ├── B.scss                  ├── B.css
    ├── C.js                    ├── C.js
    └── D.coffee                └── D.js
```
