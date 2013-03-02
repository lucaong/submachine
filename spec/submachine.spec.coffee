buster.spec.expose()

describe "Submachine", ->

  before ->
    class @M extends Submachine
    @m = new @M

  after ->
    delete @M
    delete @m

  describe "class methods", ->

    describe "hasStates", ->

      it "creates the array of states", ->
        @M.hasStates "foo", "bar", "baz"
        expect( @M::states ).toEqual ["foo", "bar", "baz"]

      it "can also accept array", ->
        @M.hasStates ["foo", "bar", "baz"]
        expect( @M::states ).toEqual ["foo", "bar", "baz"]

    describe "transition", ->

      before ->
        @M.hasStates "foo", "bar", "baz"
        @spySwitchTo = @spy()
        @stub( @m, "switchTo", @spySwitchTo )

      after ->
        delete @spySwitchTo

      it "adds a new event", ->
        @M.transition from: "foo", to: "bar", on: "baz"
        expect( @M::events.baz[0] ).toEqual from: "foo", to: "bar"

      it "defines a new instance method for the event", ->
        @M.transition from: "foo", to: "bar", on: "baz"
        expect( typeof @M::baz ).toEqual "function"

      it "defines an instance method that calls switchTo('bar') if state is 'foo'", ->
        @M.transition from: "foo", to: "bar", on: "qux"
        @m.state = "foo"
        @m.qux()
        expect( @spySwitchTo ).toHaveBeenCalledWith "bar"

      it "defines an instance method that doesn't call switchTo('bar') if state is not 'foo'", ->
        @M.transition from: "foo", to: "bar", on: "qux"
        @m.state = "baz"
        @m.qux()
        refute.calledWith @spySwitchTo, "bar"

      it "defines an instance method that calls switchTo passing extra args", ->
        @M.transition from: "foo", to: "bar", on: "qux"
        @m.state = "foo"
        @m.qux( 123, 321 )
        expect( @spySwitchTo ).toHaveBeenCalledWith "bar", 123, 321

      it "lets me define more than one transition for an event", ->
        @M.transition from: "foo", to: "bar", on: "qux"
        @M.transition from: "bar", to: "baz", on: "qux"
        @m.state = "foo"
        @m.qux()
        expect( @spySwitchTo ).toHaveBeenCalledWith "bar"
        @m.state = "bar"
        @m.qux()
        expect( @spySwitchTo ).toHaveBeenCalledWith "baz"

      it "accepts `from: '*'` as wildcard", ->
        @M.transition from: "*", to: "bar", on: "qux"
        @m.state = "baz"
        @m.qux()
        expect( @spySwitchTo ).toHaveBeenCalledWith "bar"

    describe "onEnter", ->
      it "adds an onEnter callback for the given state", ->
        cbk = ->
        @M.onEnter "foo", cbk
        expect( @M::callbacks.foo.onEnter ).toBe cbk

    describe "onLeave", ->
      it "adds an onLeave callback for the given state", ->
        cbk = ->
        @M.onLeave "foo", cbk
        expect( @M::callbacks.foo.onLeave ).toBe cbk

    describe "setupState", ->
      it "adds onEnter and onLeave callbacks for the given state", ->
        cbk1 = ->
        cbk2 = ->
        @M.setupState "foo",
          onEnter: cbk1,
          onLeave: cbk2
        expect( @M::callbacks.foo.onEnter ).toBe cbk1
        expect( @M::callbacks.foo.onLeave ).toBe cbk2

    describe "subclass", ->

      it "implements class inheritance outside CoffeeScript", ->
        sub = @M.subclass()
        expect( sub.hasStates ).toBe @M.hasStates
        expect( new sub instanceof @M ).toBeTrue()

      it "evaluates the given function in the scope of the subclass passing the prototype", ->
        probe = null
        proto = null
        sub = @M.subclass ( p ) ->
          probe = @
          proto = p
        expect( probe ).toBe sub
        expect( proto ).toBe sub::

      it "creates a subclass constructor that calls the init() method passing all arguments, if defined", ->
        spy = @spy()
        sub = @M.subclass ( proto ) ->
          @hasStates "abc"
          proto.init = spy
        new sub "abc", 123
        expect( spy ).toHaveBeenCalledOnceWith "abc", 123

  describe "inhertance", ->

    it "lets me add states on subclass without affecting superclass", ->
      @M.hasStates "foo"
      @M.transition from: "foo", to: "bar", on: "baz"
      class Sub extends @M
        @hasStates "bar"
      expect( @M::states ).toEqual ["foo"]

    it "lets me add transitions on subclass without affecting superclass", ->
      @M.transition from: "foo", to: "bar", on: "baz"
      class Sub extends @M
        @transition from: "baz", to: "foo", on: "qux"
      expect( typeof @M::events.qux ).toBe "undefined"

    it "lets me add callbacks on subclass without affecting superclass", ->
      cbk = ->
      @M.onEnter "*", cbk
      class Sub extends @M
        @onEnter "*", ->
      expect( @M::callbacks["*"].onEnter ).toBe cbk

  describe "instance metods", ->

    describe "switchTo", ->

      before ->
        @M.hasStates "foo", "bar", "baz"
        @m.state = "foo"

      it "changes state", ->
        @m.switchTo "bar"
        expect( @m.state ).toEqual "bar"

      it "throws error if state does not exist", ->
        expect( => @m.switchTo("quux") ).toThrow()

      describe "if callbacks are defined", ->

        it "invokes onLeave callback on old state passing extra args", ->
          spy = @spy()
          @M::callbacks =
            foo:
              onLeave: spy
          @m.switchTo "bar", 123, 321
          expect( spy ).toHaveBeenCalledOnceWith 123, 321

        it "invokes onEnter callback on new state passing extra args", ->
          spy = @spy()
          @M::callbacks =
            bar:
              onEnter: spy
          @m.switchTo "bar", 123, 321
          expect( spy ).toHaveBeenCalledOnceWith 123, 321

        it "invokes wildcard callbacks", ->
          spy1 = @spy()
          spy2 = @spy()
          @m.state = "foo"
          @M::callbacks =
            "*":
              onEnter: spy1
              onLeave: spy2
          @m.switchTo "bar", 123, 321
          expect( spy1 ).toHaveBeenCalledOnceWith 123, 321
          expect( spy2 ).toHaveBeenCalledOnceWith 123, 321

    describe "initState", ->
      before ->
        @M.hasStates "foo", "bar", "baz"

      it "initialize state with the given value", ->
        @m.initState "foo"
        expect( @m.state ).toEqual "foo"

      it "executes onEnter callback", ->
        cbk = @spy()
        @M.onEnter "foo", cbk
        @m.initState "foo"
        expect( cbk ).toHaveBeenCalled()

      it "throws error if called when the state is already set", ->
        @m.state = "foo"
        expect( => @m.initState "bar" ).toThrow()

    describe "constructor", ->

      it "initializes state, if a state is given", ->
        @stub @M::, "initState"
        m = new @M "foo"
        expect( @M::initState ).toHaveBeenCalledWith "foo"
