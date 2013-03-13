class Submachine

  # Private

  isArray = Array.isArray or ( maybe_array ) ->
    ({}).toString.apply( maybe_array ) is "[object Array]"

  clone = ( obj ) ->
    return obj unless obj? and typeof obj is "object"
    c = new obj.constructor()
    c[ key ] = clone obj[ key ] for key of obj
    c

  # Public class methods

  @hasStates: ( args... ) ->
    if isArray args[0]
      @::_states = args[0]
    else
      @::_states = args

  @transition: ( obj ) ->
    unless obj? and obj.from? and obj.to? and obj.on?
      throw new Error "transition must define 'from', 'to' and 'on'"

    @::_events ?= {}
    unless @::hasOwnProperty "_events"
      @::_events = clone @::_events
    @::_events[ obj.on ] ?= []
    @::_events[ obj.on ].push
      from: obj.from
      to:   obj.to
      if:   obj.if

    @::[ obj.on ] ?= ( args... ) ->
      for tr in @_events[ obj.on ]
        if @state is tr.from or tr.from is "*"
          c = if typeof tr.if is "string" then @[ tr.if ] else tr.if
          @switchTo tr.to, args... if not c? or c.call @, tr.to, args...
          break

  @_addStateCallback: ( state, type, cbk ) ->
    @::_callbacks ?= {}
    unless @::hasOwnProperty "_callbacks"
      @::_callbacks = clone @::_callbacks
    @::_callbacks[ state ] ?= {}
    @::_callbacks[ state ][ type ] ?= []
    @::_callbacks[ state ][ type ].push cbk

  @onEnter: ( state, cbk ) ->
    @_addStateCallback state, "onEnter", cbk

  @onLeave: ( state, cbk ) ->
    @_addStateCallback state, "onLeave", cbk

  @setupState: ( state, cbks = {} ) ->
    @onEnter state, cbks.onEnter if cbks.onEnter?
    @onLeave state, cbks.onLeave if cbks.onLeave?

  @subclass: ( fn ) ->
    class Subclass extends @
      constructor: ( args... ) ->
        if @initialize?
          @initialize args...
        else super args...
    fn?.call Subclass, Subclass::
    Subclass

  # Public instance methods

  constructor: ( state ) ->
    @initState state if state?

  initState: ( state ) ->
    throw new Error "state was already initialized" if @state?
    @switchTo state

  switchTo: ( state, args... ) ->
    if state not in @_states
      throw new Error "invalid state #{state}"

    @_invokeStateCallbacks @state, "onLeave", args if @state?
    @state = state
    @_invokeStateCallbacks @state, "onEnter", args

  _invokeStateCallbacks: ( state, type, args ) ->
    @_invokeStateCallbacks "*", type, args if state isnt "*"
    cbk.apply( @, args ) for cbk in @_callbacks?[ state ]?[ type ] || []

# Export as:
# CommonJS module
if exports?
  if module? and module.exports?
    exports = module.exports = Submachine
  exports.Submachine = Submachine
# AMD module
else if typeof define is "function" and define.amd
  define ->
    Submachine
# Browser global
else
  @Submachine = Submachine
