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
      @::states = args[0]
    else
      @::states = args

  @transition: ( obj ) ->
    unless obj? and obj.from? and obj.to? and obj.on?
      throw new Error "transition must define 'from', 'to' and 'on'"

    @::events ?= {}
    unless @::hasOwnProperty "events"
      @::events = clone @::events
    @::events[ obj.on ] ?= []
    @::events[ obj.on ].push
      from: obj.from,
      to:   obj.to

    @::[ obj.on ] ?= ( args... ) ->
      for tr in @events[ obj.on ]
        if @state is tr.from or tr.from is "*"
          @switchTo tr.to, args...
          break

  @_addStateCallback: ( state, type, cbk ) ->
    @::callbacks ?= {}
    unless @::hasOwnProperty "callbacks"
      @::callbacks = clone @::callbacks
    @::callbacks[ state ] ?= {}
    @::callbacks[ state ][ type ] = cbk

  @onEnter: ( state, cbk ) ->
    @_addStateCallback state, "onEnter", cbk

  @onLeave: ( state, cbk ) ->
    @_addStateCallback state, "onLeave", cbk

  @setupState: ( state, cbks = {} ) ->
    @onEnter state, cbks.onEnter if cbks.onEnter?
    @onLeave state, cbks.onLeave if cbks.onLeave?

  @subclass: ( fn ) ->
    parent = @
    sub = ( args... ) ->
      if @init?
        @init args...
      else parent.apply @, args
    sub[ prop ] = value for prop, value of parent
    sub:: = new parent
    sub::constructor = sub
    fn?.call sub, sub::
    sub

  # Public instance methods

  constructor: ( state ) ->
    @initState state if state?

  initState: ( state ) ->
    throw new Error "state was already initialized" if @state?
    @switchTo state

  switchTo: ( state, args... ) ->
    if state not in @states
      throw new Error "invalid state #{state}"

    @callbacks ?= {}

    if @state?
      @callbacks[ @state ]?.onLeave?.apply( @, args )
      @callbacks["*"]?.onLeave?.apply( @, args )

    @state = state

    @callbacks[ @state ]?.onEnter?.apply( @, args )
    @callbacks["*"]?.onEnter?.apply( @, args )

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
