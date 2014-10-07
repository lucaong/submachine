# Submachine - Kick-ass finite state machines in JavaScript and CoffeeScript

A clean and readable DSL for easily creating finite state machines in
JavaScript and CoffeeScript. With a footprint of less than 200 lines of
unminified code and with no dependency, `Submachine` works in browser and in
Node, and it can be imported with CommonJS, AMD and normal browser `<script>`.

## Installation

Either manually copy the file `lib/submachine.js` in your project or, if you
use Bower, then just run:

```
bower install submachine
```

## Usage

`Submachine` works in Node and in the browser, and has no dependency, but for
the sake of this example we assume that we need to create a toggle button
widget in the browser using jQuery:

### CoffeeScript

```coffeescript
class Toggler extends Submachine

  # Declare states
  @hasStates "on", "off"

  # Define events and transitions
  @transition from: "on",  to: "off", on: "toggle"
  @transition from: "off", to: "on",  on: "toggle"

  # Optionally define callbacks to setup/teardown states
  # (here using "*" wildcard to match any state)
  @onEnter "*", ->
    @btn.addClass( @state ).val @state
  @onLeave "*", ->
    @btn.removeClass @state
  
  constructor: ( $btn ) ->
    @btn = $btn
    # Events (like `toggle` here) are exposed as instance methods
    @btn.click => @toggle
    @initState "on"

# Instantiate
toggler = new Toggler $("button.toggle")
```

### JavaScript

JavaScript doesn't have (yet) the awesome CoffeeScript class syntax, but
`Submachine` comes to the rescue providing a `subclass` method that implements
class inheritance and accepts a function evaluated in the class scope. Also,
the `initialize` method provides functionality similar to CoffeeScript's
`constructor`.

```javascript
var Toggler = Submachine.subclass(function( proto ) {
  this.hasStates("on", "off");

  this.transition({ from: "on",  to: "off", on: "toggle" });
  this.transition({ from: "off", to: "on",  on: "toggle" });

  this.onEnter("*", function() {
    this.btn.addClass( this.state ).val( this.state );
  });
  this.onLeave("*", function() {
    this.btn.removeClass( this.state );
  });

  proto.initialize = function( $btn ) {
    var self = this;
    this.btn = $btn;
    $btn.click(function() {
      self.toggle();
    });
    this.initState("on");
  }
});

var toggler = new Toggler( $("button.toggle") );
```

## Public class methods

### hasStates

`hasStates( states )` accepts state names as different arguments or as an
array and uses them to compose the list of the valid states.

### transition

`transition( obj )` takes an object literal specifying at least an event name
triggering the transition and the name of the states the transition goes from
and to (e.g. `{ on: "open", from: "locked", to: "unlocked" }` meaning than on
event `open` the state transitions from `locked` to `unlocked`). It expose the
event as an instance method that triggers the transition to the "to" state if
called when in the "from" state. More than one transition can be defined from
the same event. Transitions are evaluated in order, so in case more than one
transition applies, only the first one gets triggered.

In addition to the required `from`, `to`, and `on` options, it is possible to
pass an `if` option specifying a condition that needs to be satisfied in order
for the transition to occur. The value of this option can be either a function
or a string. If it is a string, the instance method with that name is
evaluated. In any case, the condition is evaluated in the scope of the
instance.

### onEnter

`onEnter( state, fn )` causes the callback function `fn` to be called whenever
transitioning to state `state`. `state` can be a state name, or the special
wildcard `"*"` to mean "any state". The callback is evaluated in the scope of
the instance, and gets passed any argument passed to the event method.

### onLeave

`onLeave( state, fn )` causes the callback function `fn` to be called whenever
transitioning from state `state` to another. `state` can be a state name, or
the special wildcard `"*"` to mean "any state". The callback is evaluated in the
scope of the instance, and gets passed any argument passed to the event
method.

### setupState

`setupState( state, obj )` is a shortcut for specifying both `onEnter` and
`onLeave` callbacks at once (e.g. `setupState("locked", { onEnter: enterCbk,
onLeave: leaveCbk })`).

### subclass

`subclass( fn )` is used to implement class inheritance when Submachine is
used with plain JavaScript. It creates the subclass, evaluates `fn` in its
scope passing the instance prototype as the first argument and finally returns
the subclass, replacing CoffeeScript's `class` syntax.  Moreover, the
subclass' constructor executes the `initialize` instance method if available,
passing all the arguments, making it possible to override the constructor
logic, as in CoffeeScript's `constructor`.


## Public instance methods

### constructor

By default it does nothing but optionally getting a state name and
initializing the state with it by calling `initState`, but it can be
overridden to do other things if needed.

### initState

`initState( state )` initializes the state of the state machine to `state`,
also calling its `onEnter` callback if defined. It throws an error if called
when the state is already set.

### switchTo

`switchTo( state )` triggers a state transition to `state`, executing also the
appropriate callbacks. This method is used internally by the event methods and
normally should not be called directly.

## Contribute

  1. Fork the project and setup the environment with `npm install`
  2. Write new features and relative tests (with Buster JS)
  3. Send pull request (please do not change version number)

## Changelog

### 0.1.2

  * Available for installation as a Bower package

### 0.1.1

  * Possibility to attach multiple `onEnter` and `onLeave` callbacks for the same state

  * Add `if` conditions on transitions

  * Prefix internal properties with `_` to mark them more clearly as "private"

### 0.1.0

  * Big API change: now `Submachine` is meant to be subclassed, so most methods
    are class methods now

  * This is a new minor version release, not maintaining backward compatibility

### 0.0.2

  * `initState` throws error if called when state is already set

### 0.0.1

  * First release
