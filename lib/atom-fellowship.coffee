{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = AtomFellowship =
  subscriptions: null
  observerOnWillRemoveItem: null
  observerOnWillSwitch: null
  observerOnConfigUpdate: null
  observerOnWillDestroyPane: null
  workspace: null
  panes: null
  workspacePrepared: false
  configFellows: null
  configSplitHorizontal: null
  configOnlyFirstCloseFellows: null
  configOnlyFirstSwitchFellows: null
  configFellowsLength: null

  config:
    fellows:
      type: 'object'
      order: 1
      properties:
        fellow1:
          title: 'Fellow 1'
          description: 'Array of strings: [muchRegex, replaceStr, replaceStr]'
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
    splitHoriz:
      title: 'Side by side layout'
      order: 2
      type: 'boolean'
      default: false
    onlyFirstCloseOthers:
      title: 'Only first fellow close others'
      order: 3
      type: 'boolean'
      default: true
    onlyFirstSwitchOthers:
      title: 'Only first fellow switch others'
      order: 4
      type: 'boolean'
      default: false

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-fellowship:openFellows': => @openFellows()

    @workspace = atom.workspace

    @prepareConfig()
    @prepareWorkspace()

    @observerOnWillRemoveItem = @workspace.onDidDestroyPaneItem (e) => @closeFellows(e)
    @observerOnWillSwitch = @workspace.onDidStopChangingActivePaneItem (item) => @switchFellows(item)
    @observerOnConfigUpdate = atom.config.observe 'atom-fellowship', () => @prepareConfig()
    @observerOnWillDestroyPane = @workspace.onWillDestroyPane () => @workspacePrepared = false

  deactivate: ->
    @subscriptions.dispose()

    atom.config.set('core.destroyEmptyPanes', true)

  prepareWorkspace: ->
    @panes = @workspace.getPanes()
    i = @panes.length

    while i <= @configFellowsLength - 1
      if i is 0
#        @workspace.open()
      else if i is 1
        @panes[0].splitRight()
      else if i >= 2
        @panes[1].splitDown()

      @panes = @workspace.getPanes()
      i++

    atom.config.set('core.destroyEmptyPanes', false)

    @workspacePrepared = true

  prepareConfig: ->
    fellowConfig = []
    config = atom.config
    initialConfig = config.get('atom-fellowship').fellows

    for key, value of initialConfig
      fellowConfig.push(value)

    @configFellows = fellowConfig
    @configFellowsLength = fellowConfig.length
    @configSplitHorizontal = config.get('atom-fellowship').splitHoriz
    @configOnlyFirstCloseFellows = config.get('atom-fellowship').onlyFirstCloseOthers
    @configOnlyFirstSwitchFellows = config.get('atom-fellowship').onlyFirstSwitchOthers

  getFileTypeFromPath: (path) ->
    fileTypeNum = null
    i = 0

    for fellow in @configFellows
      if path.match(fellow[0])
        fileTypeNum = i
        break
      i++

    return fileTypeNum

  openFile: (pane, uri) ->
    if fs.existsSync(uri)
      @workspace.openURIInPane(uri, pane)

  moveFile: (pane, item) ->
    @workspace.getActivePane().moveItemToPane(item, pane)

  openFellows: ->
    activeItem = @workspace.getActivePaneItem()
    file = activeItem?.buffer?.file
    filePath = file?.path or ''
    current = @getFileTypeFromPath(filePath)
    i = 0

    # TODO: do not open already opened file

    if !filePath or filePath is '' or filePath.indexOf('atom:') isnt -1 or current is null
      return

    if not @workspacePrepared
      @prepareWorkspace()

    while i <= @configFellowsLength - 1
      if i is current
        @moveFile(@panes[current], activeItem)
      else
        @openFile(@panes[i], filePath.replace(
          @configFellows[current][1], @configFellows[i][1]).replace(
          @configFellows[current][2], @configFellows[i][2]))
      i++

  closeFellows: (e) ->
    item = e.item
    filePath = item.getURI?() or ''
    current = if @configOnlyFirstCloseFellows then 0 else @getFileTypeFromPath(filePath)
    i = 0

    if !filePath or filePath is '' or filePath.indexOf('atom:') isnt -1 or current is null
      return

    while i <= @configFellowsLength - 1
      if i isnt current
        item = @panes[i].itemForURI(
          filePath.replace(
            @configFellows[current][1], @configFellows[i][1]).replace(
            @configFellows[current][2], @configFellows[i][2]))
        @panes[i].destroyItem(item)
      i++

  switchFellows: (item) ->
    filePath = item?.getURI?() or ''
    current = if @configOnlyFirstSwitchFellows then 0 else @getFileTypeFromPath(filePath)
    i = 0

    if !filePath or filePath is '' or filePath.indexOf('atom:') isnt -1 or current is null
      return

    while i <= @configFellowsLength - 1
      if i isnt current
        item = @panes[i].itemForURI(
          filePath.replace(
            @configFellows[current][1], @configFellows[i][1]).replace(
            @configFellows[current][2], @configFellows[i][2]))
        @panes[i].activateItem(item)
      i++