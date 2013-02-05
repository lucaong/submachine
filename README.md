# Submachine

A clean and readable DSL for easily creating finite state machines. With a
footprint of less than 200 lines of code unminified and with no dependency,
`Submachine` works in browser and in Node, and it can be imported with
CommonJS, AMD and normal browser `<script>`. CoffeeScript and JavaScript
versions provided.

## Usage

Let's say we need to create a toggle button in the browser using CoffeeScript:

```coffeescript
# This example assumes jQuery is present, but Submachine
# does not depend on it in any way
$button = $(".toggle-button")

onoff = new Submachine, ->
  # Declare possible states
  @hasStates "on", "off"

  # Define events and transitions
  @transition from: "on",  to: "off", on: "toggle"
  @transition from: "off", to: "on",  on: "toggle"

  # Optionally define callbacks to setup/teardown states
  # (here using "*" wildcard to match any state)
  @setupState "*",
    onEnter: ->
      $button.addClass( @state ).val @state
    onLeave: ->
      $button.removeClass @state

  # Events (like `toggle` here) are exposed as methods
  # so it's easy to hook them to browser events
  $button.click @toggle

  # Initialize state
  @initState "on"
```

## Methods

### constructor

You can pass a function to the constructor `new Submachine( func )`, and it
will be executed in the scope of the new instance. This makes it easy to group
in the same code block all the state machine definition code.

### hasStates

`hasStates( states )` accepts state names as different arguments or as an array
and uses them to compose the list of the valid states.

### transition

`transition( obj )` usually takes an object literal specifying an event name
triggering the transition and the name of the states the transition goes from
and to (e.g. `{ on: "open", from: "locked", to: "unlocked" }` meaning than on
event "open" the state transitions from "locked" to "unlocked"). It defines a
method with the same name as the event, that triggers the transition to the
"to" state if called when in the "from" state. More than one transition can be
defined from the same event. Transitions are evaluated in order, so in case
more than one transition applies, only the first one gets triggered.

### onEnter

`onEnter( state, fn )` causes the callback function `fn` to be called whenever
transitioning to state `state`. `state` can be a state name, or the special
wildcard "*" to mean "any state". The callback gets passed any argument passed
to the event method.

### onLeave

`onLeave( state, fn )` causes the callback function `fn` to be called whenever
transitioning from state `state` to another. `state` can be a state name, or
the special wildcard "*" to mean "any state". The callback gets passed any
argument passed to the event method.

### setupState

`setupState( state, obj )` is a shortcut for specifying both `onEnter` and
`onLeave` callbacks at once (e.g. `setupState("locked", { onEnter: enterCbk,
onLeave: leaveCbk })`).

### initState

`initState( state )` is used to initialize the state of the state machine to
`state`, also calling its `onEnter` callback if defined. It throws an error if
called when the state is already set.

### switchTo

`switchTo( state )` triggers a state transition to `state` executing also the
appropriate callbacks. This method is used internally by the event methods and
normally should not be called directly.

## Contribute

  1. Fork the project and setup the environment with `npm install`
  2. Write new features and relative tests (with Buster JS)
  3. Send pull request (please do not change version number)

## Changelog

### 0.0.2

  * `initState` throws error if called when state is already set

### 0.0.1

  * First release
