{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = Fellowship =
  subscriptions: null
  observerOnWillRemoveItem: null
  workspace: null
  panes: null
  paneLeft: null
  paneRightTop: null
  paneRightBottom: null

  config:
    fellow1:
      title: 'Fellow 1'
      description: 'Array of strings: [regexp to much, replace1, replace2...]'
      order: 1
      type: 'array'
      default: ['.*lib\/definitions.*.scss', 'lib/definitions', '_acdc-']
      items:
        type: 'string'
    fellow2:
      title: 'Fellow 2'
      order: 2
      type: 'array'
      default: ['.*sass\/definitions.*.scss', 'styleguide-src/sass/definitions', '_']
      items:
        type: 'string'
    fellow3:
      title: 'Fellow 3'
      order: 3
      type: 'array'
      default: ['.*sass\/bindings.*.scss', 'styleguide-src/sass/bindings', '_']
      items:
        type: 'string'

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'fellowship:openFellows': => @openFellows()

    @workspace = atom.workspace

    @observerOnWillRemoveItem = atom.workspace.onWillDestroyPaneItem (e) => @closeFellows(e)
    @observerOnWillSwitch = atom.workspace.onDidStopChangingActivePaneItem (item) => @switchFellows(item)

  deactivate: ->
    @subscriptions.dispose()
    atom.config.set('core.destroyEmptyPanes', true)

  prepareWorkspace: ->
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
    config = atom.config.get('fellowship')

    if !filePath || filePath == ''
      return

    @prepareWorkspace()

    if filePath.match(config.fellow1[0])
      @moveFile(@paneLeft, activeItem)
      @openFile(@paneRightTop, filePath.replace(config.fellow1[1], config.fellow2[1]).replace(config.fellow1[2], config.fellow2[2]))
      @openFile(@paneRightBottom, filePath.replace(config.fellow1[1], config.fellow3[1]).replace(config.fellow1[2], config.fellow3[2]))
    else if filePath.match(config.fellow2[0])
      @openFile(@paneLeft, filePath.replace(config.fellow2[1], config.fellow1[1]).replace(config.fellow2[2], config.fellow1[2]))
      @moveFile(@paneRightTop, activeItem)
      @openFile(@paneRightBottom, filePath.replace(config.fellow2[1], config.fellow3[1]))
    else if filePath.match(config.fellow3[0])
      @openFile(@paneLeft, filePath.replace(config.fellow3[1], config.fellow1[1]).replace(config.fellow3[2], config.fellow1[2]))
      @openFile(@paneRightTop, filePath.replace(config.fellow3[1], config.fellow2[1]))
      @moveFile(@paneRightBottom, activeItem)
    else
      console.log "Fellowship not found any fellows"

  closeFellows: (e) ->
    item = e.item
    filePath = item.getURI?()
    config = atom.config.get('fellowship')

    if !filePath || filePath == ''
      return

    if filePath.match(config.fellow1[0])
      item1 = @paneRightTop.itemForURI(filePath.replace(config.fellow1[1], config.fellow2[1]).replace(config.fellow1[2], config.fellow2[2]))
      item2 = @paneRightBottom.itemForURI(filePath.replace(config.fellow1[1], config.fellow3[1]).replace(config.fellow1[2], config.fellow3[2]))
      @paneRightTop.destroyItem(item1)
      @paneRightBottom.destroyItem(item2)
    else
      console.log "Fellowship not close any fellows"

  switchFellows: (item) ->
    filePath = item?.getURI?()
    config = atom.config.get('fellowship')

    if !filePath || filePath == ''
      return

    if filePath.match(config.fellow1[0])
      item1 = @paneRightTop.itemForURI(filePath.replace(config.fellow1[1], config.fellow2[1]).replace(config.fellow1[2], config.fellow2[2]))
      item2 = @paneRightBottom.itemForURI(filePath.replace(config.fellow1[1], config.fellow3[1]).replace(config.fellow1[2], config.fellow3[2]))
      @paneRightTop.activateItem(item1)
      @paneRightBottom.activateItem(item2)
    else
      console.log "Fellowship not switch any fellows"
