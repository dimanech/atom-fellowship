{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = Fellowship =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'fellowship:openFellows': => @openFellows()

  deactivate: ->
    @subscriptions.dispose()

  openFile: (uri) ->
    if fs.existsSync(uri)
      atom.workspace.open(uri, {
        searchAllPanes: true,
        activatePane: false
      })

  openFellows: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path

    if filePath.match(/.*sass\/definitions.*.scss/)
      @openFile(filePath.replace('styleguide-src/sass/definitions', 'lib/definitions').replace('_', '_acdc-'))
      @openFile(filePath.replace('styleguide-src/sass/definitions', 'styleguide-src/sass/bindings'))
    else if filePath.match(/.*lib\/definitions.*.scss/)
      @openFile(filePath.replace('lib/definitions', 'styleguide-src/sass/definitions').replace('_acdc-', '_'))
      @openFile(filePath.replace('lib/definitions', 'styleguide-src/sass/bindings').replace('_acdc-', '_'))
    else if filePath.match(/.*sass\/bindings.*.scss/)
      @openFile(filePath.replace('styleguide-src/sass/bindings', 'styleguide-src/sass/definitions'))
      @openFile(filePath.replace('styleguide-src/sass/bindings', 'lib/definitions').replace('_', '_acdc-'))
    else
      console.log 'openFellow not found anything'
