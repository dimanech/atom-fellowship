# Atom Fellowship

[![Code Climate](https://codeclimate.com/github/dimanech/atom-fellowship/badges/gpa.svg)](https://codeclimate.com/github/dimanech/atom-fellowship)

> ‘I will take the Ring,’ he said, ‘though I do not know the way.’ J.R.R Tolkien

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

For configuring fellows you need to provide array with 3 values

* String with Regex. Used to much needed file.
* String for replace. Used to replace path in files. As usual this is folders names.
* String for replace. Most cases this is some namespace. As usual this is file extension or namespace.

### Examples

#### Much extension only

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

#### Much directory and extension

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

#### Much not equal directories and namespaces

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

#### Much not equal directories namespace and different file types

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

This plugin cannot cover cases where:

* one fellow has namespace and other don't have one. Because `""` cannot replace `"ns-"`. Plugin will work only on namespaced files.

#### More than 3 fellows

If you need you can do even more by adding unlimited fellows via your config.cson

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

## Getting started

* Press `shift-alt-F` to load plugin and open all related files
* Close first pane file to close all related files
* Switch first pane files to switch all fellows

## Settings

* `splitHoriz:false` side by side layout
* `onlyFirstCloseOthers:true` only first fellow close others
* `onlyFirstSwitchOthers:false` only first fellow switch others 

## Keyboard Shortcut

`atom-fellowship:openFellows`, default `shift-alt-F`: load plugin and open all related files

## Help out

Work on this plugin is still in progress, any help is welcome.

## License

MIT © Dima Nechepurenko
