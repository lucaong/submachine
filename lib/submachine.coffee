class Submachine

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

    @events ?= {}
    @events[ obj.on ] ?= []
    @events[ obj.on ].push
      from: obj.from,
      to:   obj.to

    @[ obj.on ] ?= ( args... ) ->
      for tr in @events[ obj.on ]
        if @state is tr.from or tr.from is "*"
          @switchTo tr.to, args...
          break

  switchTo: ( state, args... ) ->
    throw new Error "invalid state #{state}" if not contains @states, state
    @callbacks           ?= {}
    @callbacks[ @state ] ?= {}
    @callbacks[ state ]  ?= {}

    if @state? and @callbacks[ @state ].onLeave?
      @callbacks[ @state ].onLeave.apply( @, args )

    @state = state

    if @callbacks[ @state ].onEnter?
      @callbacks[ @state ].onEnter.apply( @, args )

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
