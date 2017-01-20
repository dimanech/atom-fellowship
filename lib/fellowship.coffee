{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = Fellowship =
  subscriptions: null
  workspace: null
  paneLeft: null
  paneRightTop: null
  paneRightBottom: null
  panes: null
  observerOnWillRemoveItem: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'fellowship:openFellows': => @openFellows()

    @prepareWorkspace()

    @observerOnWillRemoveItem = atom.workspace.onWillDestroyPaneItem (e) => @closeFellows(e)
    @observerOnWillSwitch = atom.workspace.onDidStopChangingActivePaneItem (item) => @switchFellows(item)

  deactivate: ->
    @subscriptions.dispose()

    atom.config.set('core.destroyEmptyPanes', true)

  prepareWorkspace: ->
    @workspace = atom.workspace
    @panes = @workspace.getPanes()

    if @panes.length == 0
      @workspace.open()

    if @panes.length == 1
      @panes[0].splitRight()
      @panes = @workspace.getPanes()

    if @panes.length == 2
      @panes[1].splitDown()
      @panes = @workspace.getPanes()

    @paneLeft = @panes[0]
    @paneRightTop = @panes[1]
    @paneRightBottom = @panes[2]

    atom.config.set('core.destroyEmptyPanes', false)

  openFile: (pane, uri) ->
    if fs.existsSync(uri)
      @workspace.openURIInPane(uri, pane)

  moveFile: (pane, item) ->
    @workspace.getActivePane().moveItemToPane(item, pane)

  openFellows: ->
    activeItem = @workspace.getActivePaneItem()
    file = activeItem?.buffer?.file
    filePath = file?.path

    if !filePath || filePath == ''
      return

    if filePath.match(/.*sass\/definitions.*.scss/)
      @moveFile(@paneRightTop, activeItem)
      @openFile(@paneLeft, filePath.replace('styleguide-src/sass/definitions', 'lib/definitions').replace('_', '_acdc-'))
      @openFile(@paneRightBottom, filePath.replace('styleguide-src/sass/definitions', 'styleguide-src/sass/bindings'))
    else if filePath.match(/.*lib\/definitions.*.scss/)
      @moveFile(@paneLeft, activeItem)
      @openFile(@paneRightTop, filePath.replace('lib/definitions', 'styleguide-src/sass/definitions').replace('_acdc-', '_'))
      @openFile(@paneRightBottom, filePath.replace('lib/definitions', 'styleguide-src/sass/bindings').replace('_acdc-', '_'))
    else if filePath.match(/.*sass\/bindings.*.scss/)
      @moveFile(@paneRightBottom, activeItem)
      @openFile(@paneRightTop, filePath.replace('styleguide-src/sass/bindings', 'styleguide-src/sass/definitions'))
      @openFile(@paneLeft, filePath.replace('styleguide-src/sass/bindings', 'lib/definitions').replace('_', '_acdc-'))
    else
      console.log "Fellowship not found any fellows"

  closeFellows: (e) ->
    item = e.item
    filePath = item.getURI?()

    if !filePath || filePath == ''
      return

    if filePath.match(/.*lib\/definitions.*.scss/)
      item1 = @paneRightTop.itemForURI(filePath.replace('lib/definitions', 'styleguide-src/sass/definitions').replace('_acdc-', '_'))
      item2 = @paneRightBottom.itemForURI(filePath.replace('lib/definitions', 'styleguide-src/sass/bindings').replace('_acdc-', '_'))
      @paneRightTop.destroyItem(item1)
      @paneRightBottom.destroyItem(item2)
#
# autosave package: Uncaught RangeError: Maximum call stack size exceeded
#

#    else if filePath.match(/.*sass\/definitions.*.scss/)
#      item1 = @paneLeft.itemForURI(filePath.replace('styleguide-src/sass/definitions', 'lib/definitions').replace('_', '_acdc-'))
#      item2 = @paneRightBottom.itemForURI(filePath.replace('styleguide-src/sass/definitions', 'styleguide-src/sass/bindings'))
#      @paneLeft.destroyItem(item1)
#      @paneRightBottom.destroyItem(item2)
#    else if filePath.match(/.*sass\/bindings.*.scss/)
#      item1 = @paneRightTop.itemForURI(filePath.replace('styleguide-src/sass/bindings', 'styleguide-src/sass/definitions'))
#      item2 = @paneLeft.itemForURI(filePath.replace('styleguide-src/sass/bindings', 'lib/definitions').replace('_', '_acdc-'))
#      @paneRightTop.destroyItem(item1)
#      @paneLeft.destroyItem(item2)
    else
      console.log "Fellowship not close any fellows"

  switchFellows: (item) ->
    filePath = item.getURI?()

    if !filePath || filePath == ''
      return

    if filePath.match(/.*lib\/definitions.*.scss/)
      item1 = @paneRightTop.itemForURI(filePath.replace('lib/definitions', 'styleguide-src/sass/definitions').replace('_acdc-', '_'))
      item2 = @paneRightBottom.itemForURI(filePath.replace('lib/definitions', 'styleguide-src/sass/bindings').replace('_acdc-', '_'))
      @paneRightTop.activateItem(item1)
      @paneRightBottom.activateItem(item2)
    else
      console.log "Fellowship not switch any fellows"
