# Atom Fellowship

> ‘I will take the Ring,’ he said, ‘though I do not know the way.’ J.R.R Tolkien

Atom plugin for operating with group of related files as single file (opening, switchin, closing). You can open files in split view and easily navigate around all fellows.

## Installation

Using `apm`:

```
apm install atom-fellowship
```

Or search for `atom-fellowship` in Atom settings view.

## Configuration

For configuring fellows you need to provide array with 3 values

* String with Regex. Used to much needed file.
* String with that differs one fellow to another. Used to replace path in files. This should be delta of path trough all fellows.
* Optional string for replace. Most cases this is namespace for file name.

Note: If you have problems with **escape sequences**, you can add this string manually in `Application: Open you config`.

### Configuration examples

Configuration for simple header-source project structure

```
./inc/file.h
./src/file.c
```

will be like this:

```js
['.*inc.*.h', '.h', '']
['.*src.*.c', '.c', '']
```

Configuration for simple MVC project structure

```
./project/controllers/file.js
./project/views/file.xml
./project/styles/file.css
```

will be like this:

```js
['.*controllers.*.js', '/controllers/', '.js']
['.*views.*.xml', '/views/', '.xml']
['.*styles.*.css', '/styles/', '.css']
```

More complex structure with namespaces:

```
./lib/controllers/re-file.js
./prj/controllers/file.js
./prj/styles/file.css
```

Will be like this:

```js
['.*lib\/controllers/.*.js', 'lib/controllers/', '.js']
['.*prj\/controllers/.*.js', 'prj/controllers/', '.js']
['.*prj\/styles.*.css', 'prj/styles/', '.css']
```

## Getting started

Press `ctrl-alt-f` to load plugin and open all related files.

Close first pane file to close all related files, switch first pane files to switch all fellows.

## Features

* Open related files in split view
* Synchronous tab switch
* Synchronous tab close
* Config for switch and close only with first file
* Option for vertical side-by-side split view

## License

MIT © Dima Nechepurenko
