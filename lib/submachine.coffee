class SubMachine

  # Private

  isArray = ( maybe_array ) ->
    return ({}).toString.apply( maybe_array ) is "[object Array]"

  contains = ( array, item ) ->
    if array.indexOf?
      return array.indexOf( item ) >= 0
    else
      return true for elem in array when elem is item
    false

  # Public

  constructor: ( fn ) ->
    fn.call @ if typeof fn is "function"

  hasStates: ( args... ) ->
    if isArray args[0]
      @states = args[0]
    else
      @states = args

  transition: ( obj ) ->
    unless obj? and obj.from? and obj.to? and obj.on?
      throw new Error "transition must define 'from', 'to' and 'on'"

    @[ obj.on ] = ->
      @switchTo obj.to if @state is obj.from or obj.from is "*"

  switchTo: ( state ) ->
    throw new Error "invalid state #{state}" if not contains @states, state
    @callbacks           ?= {}
    @callbacks[ @state ] ?= {}
    @callbacks[ state ]  ?= {}

    @callbacks[ @state ].onLeave() if @state? and @callbacks[ @state ].onLeave?
    @state = state
    @callbacks[ @state ].onEnter() if @callbacks[ @state ].onEnter?

  onEnter: ( state, cbk ) ->
    @callbacks ?= {}
    @callbacks[ state ] ?= {}
    @callbacks[ state ].onEnter = cbk

  onLeave: ( state, cbk ) ->
    @callbacks ?= {}
    @callbacks[ state ] ?= {}
    @callbacks[ state ].onLeave = cbk

  setupState: ( state, cbks = {} ) ->
    @onEnter state, cbks.onEnter if cbks.onEnter?
    @onLeave state, cbks.onLeave if cbks.onLeave?

  initState: ( state ) ->
    @switchTo state

# Export
window.SubMachine = SubMachine
