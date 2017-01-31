# Atom Fellowship

[![Code Climate](https://codeclimate.com/github/dimanech/atom-fellowship/badges/gpa.svg)](https://codeclimate.com/github/dimanech/atom-fellowship)

> ‘I will take the Ring,’ he said, ‘though I do not know the way.’ J.R.R Tolkien

![Fellowship screencast](https://raw.github.com/dimanech/atom-fellowship/master/fellowship-screencast.gif)

Atom plugin for operating with group of related files as single file (opening, switchin, closing). You can open files in split view and easily navigate around all fellows.

## Features

* Open related files in split view
* Synchronous tab switch
* Synchronous tab close
* Config for switch and close only with first file
* Option for vertical side-by-side split view

## Installation

Using `apm`:

```
apm install atom-fellowship
```

Or search for `atom-fellowship` in Atom settings view.

## Configuration

For configuring fellows you need to provide array with 3 (or more. See below) values:

1. String with Regex. Used to much needed file.
2. String for replace. Used to replace path in files. As usual this is folders names.
3. String for replace. Most cases this is some namespace. As usual this is file extension or namespace.

### Examples

#### Match extension only

Configuration for simple header-source project structure

```
./inc/file.h
./src/file.c
```

will be like this:

```
.*inc.*.h, .h
.*src.*.c, .c
```

#### Match directory and extension

Configuration for simple MVC project structure

```
./project/controllers/file.js
./project/views/file.xml
./project/styles/file.css
```

will be like this:

```
.*controllers.*.js, /controllers/, .js
.*views.*.xml, /views/, .xml
.*styles.*.css, /styles/, .css
```

#### Match not equal directories and namespaces

```
./lib/controllers/ns-file.js
./prj/controllers/_file.js
./prj/views/_file.js
```

Configuration:

```
.*lib\/controllers/.*.js, lib/controllers/, _ns-
.*prj\/controllers/.*.js, prj/controllers/, _
.*prj\/views.*.js, prj/views/, _
```

#### Match not equal directories namespace and different file types

```
./lib/controllers/foo-file.js
./prj/controllers/bar-file.js
./prj/styles/baz-file.css
```

Configuration:

```
.*lib\/controllers/.*.js, lib/controllers/, foo-, .js
.*prj\/controllers/.*.js, prj/controllers/, bar-, .js
.*prj\/styles.*.css, prj/styles/, baz-, .css
``` 

Check your config by opening `Application: Open your config` for any cases.

#### More than 3 fellows

If you need you can add more than 3 fellows via your config.cson. But not more than 9 because this is limitation of Fellowship of the Ring!

```cson
fellow1: [
	".*lib\\/controllers/.*.js"
	"lib/controllers/ns-"
	"foo-"
	".js"
]
fellow2: [
	".*prj\\/controllers/.*.js"
	"prj/controllers/"
	"bar-"
	".js"
]
fellow3: [
	".*prj\\/styles.*.css"
	"prj/styles/"
	"baz-"
	".css"
]
fellow4: [
	".*prj\\/views.*.xml"
	"prj/views/"
	"waldo-"
	".xml"
]
```

#### More than 3 replace

You can add more than 3 replace strings, but probably you don't need that.

### Windows machines

Please note that Windows FS paths should be like this:

In Atom config:

```
*some\\path*.scss
some\replace
```

In cson should be:

```cson
".*lib\\\\definitions.*.scss"
"lib\\definitions"
"_acdc-"
```

## Limitations

This plugin cannot cover cases where:

* one fellow has namespace and other don't have one. Because `""` cannot replace `"ns-"`. Plugin will work only on namespaced files, and you can use settings to somehow work with this.
* to be continued ;)

## Getting started

* Press `shift-alt-F` to load plugin and open all related files or `shift-alt-C` to create fellows
* Close first pane file to close all related files
* Switch first pane files to switch all fellows

## Settings

* `splitHoriz:false` side by side layout
* `onlyFirstCloseOthers:true` only first fellow close others
* `onlyFirstSwitchOthers:false` only first fellow switch others
* `openEvenIfNotExist:false` create fellows if they not exist on open

## Keyboard Shortcut

`atom-fellowship:openFellows`, default `shift-alt-F`: load plugin and open all related files
`atom-fellowship:createFellows`, default `shift-alt-C`: load plugin and create all related files

## Help out

Work on this plugin is still in progress, any help is welcome.

## License

MIT © Dima Nechepurenko
