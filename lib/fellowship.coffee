{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = Fellowship =
  subscriptions: null
  observerOnWillRemoveItem: null
  observerOnWillSwitch: null
  observerOnConfigUpdate: null
  workspace: null
  panes: null
  workspacePrepared: false
  configFellows: null
  configSplitHoriz: null
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
          default: ['.*sass\/definitions.*.scss',
            'styleguide-src/sass/definitions', '_']
          items:
            type: 'string'
        fellow3:
          title: 'Fellow 3'
          order: 3
          type: 'array'
          default: ['.*sass\/bindings.*.scss', 'styleguide-src/sass/bindings',
            '_']
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
      'fellowship:openFellows': => @openFellows()

    @workspace = atom.workspace

    @prepareConfig()
    @prepareWorkspace()

    @observerOnWillRemoveItem = atom.workspace.onDidDestroyPaneItem (e) => @closeFellows(e)
    @observerOnWillSwitch = atom.workspace.onDidStopChangingActivePaneItem (item) => @switchFellows(item)
    @observerOnConfigUpdate = atom.config.observe 'fellowship', () => @prepareConfig()

  deactivate: ->
    @subscriptions.dispose()
    atom.config.set('core.destroyEmptyPanes', true)

  prepareWorkspace: ->
    i = 0
    @panes = @workspace.getPanes()

    if @panes.length is 0
      @workspace.open()

    if @panes.length is 1
      @panes[0].splitRight()
      @panes = @workspace.getPanes()

    if @panes.length >= 2
      while i <= @configFellowsLength - 2
        if @configSplitHoriz then @panes[1].splitRight() else @panes[1].splitDown()
        i++
      @panes = @workspace.getPanes()

    atom.config.set('core.destroyEmptyPanes', false)

    @workspacePrepared = true

  prepareConfig: ->
    fellowConfig = []
    initialConfig = atom.config.get('fellowship').fellows

    for key, value of initialConfig
      fellowConfig.push(value)

    @configFellows = fellowConfig
    @configFellowsLength = fellowConfig.length - 1
    @configSplitHoriz = atom.config.get('fellowship').splitHoriz
    @configOnlyFirstCloseFellows = atom.config.get('fellowship').onlyFirstCloseOthers
    @configOnlyFirstSwitchFellows = atom.config.get('fellowship').onlyFirstSwitchOthers

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

    if !filePath or filePath is '' or filePath.indexOf('atom:') isnt -1 or current is null
      return

    if not @workspacePrepared
      @prepareWorkspace()

    while i <= @configFellowsLength
      if i is current
        @moveFile(Fellowship.panes[current], activeItem)
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

    while i <= @configFellowsLength
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

    while i <= @configFellowsLength
      if i isnt current
        item = @panes[i].itemForURI(
          filePath.replace(
            @configFellows[current][1], @configFellows[i][1]).replace(
              @configFellows[current][2], @configFellows[i][2]))
        @panes[i].activateItem(item)
      i++
