# Submachine

A clean and readable DSL for easily creating finite state machines. With a footprint of less than 200 lines of code unminified and with no dependency, `Submachine` works in browser and in Node, and it can be imported with CommonJS, AMD and normal browser `<script>`. CoffeeScript and JavaScript versions provided.

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
```

## Contribute

  1. Fork the project and setup the environment with `npm install`
  2. Write new features and relative tests (with Buster JS)
  3. Send pull request (please do not change version number)
