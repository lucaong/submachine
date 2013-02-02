buster.spec.expose()

describe "SubMachine", ->

  before ->
    @m = new SubMachine

  after ->
    delete @m

  describe "hasStates", ->

    it "creates the array of states", ->
      @m.hasStates "foo", "bar", "baz"
      expect( @m.states ).toEqual ["foo", "bar", "baz"]

    it "can also accept array", ->
      @m.hasStates ["foo", "bar", "baz"]
      expect( @m.states ).toEqual ["foo", "bar", "baz"]
  
  describe "switchTo", ->

    before ->
      @m.hasStates "foo", "bar", "baz"
      @m.state = "foo"

    it "changes state", ->
      @m.switchTo "bar"
      expect( @m.state ).toEqual "bar"

    it "throws error if state does not exist", ->
      expect( => @m.switchTo("quux") ).toThrow()

    it "invokes onLeave callback on old state if defined", ->
      spy = @spy()
      @m.callbacks =
        foo:
          onLeave: spy
      @m.switchTo "bar"
      expect( spy ).toHaveBeenCalledOnce()

    it "invokes onEnter callback on new state if defined", ->
      spy = @spy()
      @m.callbacks =
        bar:
          onEnter: spy
      @m.switchTo "bar"
      expect( spy ).toHaveBeenCalledOnce()

  describe "transition", ->

    before ->
      @m.hasStates "foo", "bar", "baz"
      @spySwitchTo = @spy()
      @stub( @m, "switchTo", @spySwitchTo )

    it "defines a new method for the event", ->
      @m.transition from: "foo", to: "bar", on: "baz"
      expect( typeof @m.baz ).toEqual "function"

    it "defines a method that calls switchTo('bar') if state is 'foo'", ->
      @m.transition from: "foo", to: "bar", on: "qux"
      @m.state = "foo"
      @m.qux()
      expect( @spySwitchTo ).toHaveBeenCalledWith "bar"
    
    it "defines a method that doesn't call switchTo('bar') if state is not 'foo'", ->
      @m.transition from: "foo", to: "bar", on: "qux"
      @m.state = "baz"
      @m.qux()
      refute.calledWith @spySwitchTo, "bar"

    it "accepts `from: '*'` as wildcard", ->
      @m.transition from: "*", to: "bar", on: "qux"
      @m.state = "baz"
      @m.qux()
      expect( @spySwitchTo ).toHaveBeenCalledWith "bar"

  describe "onEnter", ->
    it "adds an onEnter callback for the given state", ->
      cbk = ->
      @m.onEnter "foo", cbk
      expect( @m.callbacks.foo.onEnter ).toBe cbk

  describe "onLeave", ->
    it "adds an onLeave callback for the given state", ->
      cbk = ->
      @m.onLeave "foo", cbk
      expect( @m.callbacks.foo.onLeave ).toBe cbk

  describe "setupState", ->
    it "adds onEnter and onLeave callbacks for the given state", ->
      cbk1 = ->
      cbk2 = ->
      @m.setupState "foo",
        onEnter: cbk1,
        onLeave: cbk2
      expect( @m.callbacks.foo.onEnter ).toBe cbk1
      expect( @m.callbacks.foo.onLeave ).toBe cbk2

  describe "initState", ->
    before ->
      @m.hasStates "foo", "bar", "baz"

    it "initialize state with the given value", ->
      @m.initState "foo"
      expect( @m.state ).toEqual "foo"

    it "executes onEnter callback", ->
      cbk = @spy()
      @m.onEnter "foo", cbk
      @m.initState "foo"
      expect( cbk ).toHaveBeenCalled()

  describe "constructor", ->
    it "executes funtion in the scope of the new object if given", ->
      probe = null
      m = new SubMachine ->
        probe = @
      expect( probe ).toBe m
