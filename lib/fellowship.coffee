{CompositeDisposable} = require 'atom'
fs = require 'fs'

module.exports = Fellowship =
  subscriptions: null
  observerOnWillRemoveItem: null
  observerOnWillSwitch: null
  observerOnConfigUpdate: null
  workspace: null
  panes: null
  fellowConfig: null

  config:
    fellows:
      type: 'object'
      order: 1
      properties:
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
    splitHoriz:
      title: 'Side by side layout'
      description: 'Do we need to split panels horizontally'
      order: 2
      type: 'boolean'
      default: false

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'fellowship:openFellows': => @openFellows()

    @workspace = atom.workspace

    @prepareConfig()

    @observerOnWillRemoveItem = atom.workspace.onWillDestroyPaneItem (e) => @closeFellows(e)
    @observerOnWillSwitch = atom.workspace.onDidStopChangingActivePaneItem (item) => @switchFellows(item)
    @observerOnConfigUpdate = atom.config.observe 'fellowship', () => @prepareConfig()

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
      if atom.config.get('fellowship').splitHoriz then @panes[1].splitRight() else @panes[1].splitDown()
      @panes = @workspace.getPanes()

    atom.config.set('core.destroyEmptyPanes', false)

  prepareConfig: ->
    fellowConfig = []
    initialConfig = atom.config.get('fellowship').fellows
    for key, value of initialConfig
      fellowConfig.push(value)
    @fellowConfig = fellowConfig

  getFileTypeFromPath: (path) ->
    fileTypeNum = null
    i = 0
    for fellow in @fellowConfig
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
    filePath = file?.path
    current = @getFileTypeFromPath(filePath)

    if !filePath || filePath == ''
      return

    @prepareWorkspace()

    for i in [0,1,2]
      if i == current
        @moveFile(Fellowship.panes[current], activeItem)
      else
        @openFile(@panes[i], filePath.replace(
            @fellowConfig[current][1], @fellowConfig[i][1]).replace(
              @fellowConfig[current][2], @fellowConfig[i][2]))

  closeFellows: (e) ->
    item = e.item
    filePath = item.getURI?() or ''

    if !filePath || filePath == ''
      return

    if @getFileTypeFromPath(filePath) == 0
      current = 0
      for i in [1,2]
        item = @panes[i].itemForURI(
          filePath.replace(
            @fellowConfig[current][1],
            @fellowConfig[i][1]
          ).replace(
            @fellowConfig[current][2],
            @fellowConfig[i][2]
          )
        )
        Fellowship.panes[i].destroyItem(item)

#    closes = (current) ->
#      for i in [0,1,2]
#        if i != current
#          item = Fellowship.panes[i].itemForURI(
#            filePath.replace(
#              Fellowship.fellowConfig[current][1],
#              Fellowship.fellowConfig[i][1]
#            ).replace(
#              Fellowship.fellowConfig[current][2],
#              Fellowship.fellowConfig[i][2]
#            )
#          )
#          Fellowship.panes[i].destroyItem(item)
#
#    closes(@getFileTypeFromPath(filePath))

  switchFellows: (item) ->
    filePath = item?.getURI?() or ''
    current = @getFileTypeFromPath(filePath)

    if !filePath or filePath == '' or filePath.indexOf('atom:') != -1
      return

    for i in [0,1,2]
      if i != current
        item = @panes[i].itemForURI(
          filePath.replace(
            @fellowConfig[current][1],
            @fellowConfig[i][1]
          ).replace(
            @fellowConfig[current][2],
            @fellowConfig[i][2]
          )
        )
        @panes[i].activateItem(item)
