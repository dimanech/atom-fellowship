AtomFellowship = require '../lib/atom-fellowship'

describe "AtomFellowship", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('atom-fellowship')
