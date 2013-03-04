class Submachine

  # Private

  isArray = ( maybe_array ) ->
    return ({}).toString.apply( maybe_array ) is "[object Array]"

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

    @[ obj.on ] ?= ( args... ) =>
      for tr in @events[ obj.on ]
        if @state is tr.from or tr.from is "*"
          @switchTo tr.to, args...
          break

  switchTo: ( state, args... ) ->
    if state not in @states
      throw new Error "invalid state #{state}"

    @callbacks           ?= {}
    @callbacks[ @state ] ?= {}
    @callbacks[ state ]  ?= {}
    @callbacks["*"]      ?= {}

    if @state?
      if @callbacks[ @state ].onLeave?
        @callbacks[ @state ].onLeave.apply( @, args )
      if @callbacks["*"].onLeave?
        @callbacks["*"].onLeave.apply( @, args )

    @state = state

    if @callbacks[ @state ].onEnter?
      @callbacks[ @state ].onEnter.apply( @, args )
    if @callbacks["*"].onEnter?
      @callbacks["*"].onEnter.apply( @, args )

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
    throw new Error "state was already initialized" if @state?
    @switchTo state

  toDOT: ( name ) ->
    dot = "digraph #{name||'submachine'} {\n"
    for state in @states
      dot += "  #{state} [label=\"#{state}\"];\n"
    for event, transitions of @events
      for t in transitions
        dot += "  #{t.from} -> #{t.to} [label=\"#{event}\"];\n"
    dot += "}"

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
