# Lustre Frontend Counter and Form

<div class="syllabus" markdown="1">

-   Lustre compiles Gleam to JavaScript and runs the Elm architecture in the browser.
-   The model is a plain record;
    `update` is a pure function that returns a new model;
    `view` is a pure function that returns a virtual DOM tree.
-   The runtime owns the event loop:
    it calls `update` when a message arrives and `view` to render the result.
-   There is no `setState`, no hooks, and no mutation:
    all state lives in the model and all logic lives in `update`.
-   The HTML DSL uses Gleam functions (`html.div`, `html.button`)
    rather than a template language.

</div>

## The Elm Architecture

-   [Lustre][lustre] brings the [Elm][elm] architecture to Gleam with three parts:
    -   Model: the application state, a plain record
    -   Update: a pure function `(Model, Msg) -> Model` that handles every user action
    -   View: a pure function `Model -> Element(Msg)` that produces
         a [%g virtual_dom "virtual DOM tree" %]
-   The Lustre runtime renders the view, listens for events,
    converts them to `Msg` values, calls `update`, re-renders, and repeats
-   The application code never touches the DOM directly

## Types

[%inc src/counter_demo.gleam mark=model_msg_type %]

-   `Model(count: Int)` is the entire application state
-   `Msg` lists every action the user can take: `Increment`, `Decrement`, `Reset`
-   Adding a new feature means adding a variant to `Msg` and a branch to `update`
    -   The compiler flags every case that is not handled

## Update

[%inc src/counter_demo.gleam mark=update_fn %]

-   Each branch returns a new `Model` with the count changed
-   No mutation: `Model(model.count + 1)` creates a new record

## View

-   In a browser application, `view` returns Lustre's `Element(Msg)` type:

[%inc snippets/browser.gleam mark=html_view_fn %]

-   `html.div(attrs, children)` mirrors `<div>...</div>`
-   `event.on_click(Increment)` attaches a click listener that sends `Increment` to `update`
-   `html.text` renders a string as a text node
-   The return type `Element(Msg)` guarantees that
     every event this tree can fire is a valid `Msg`

## Console Demo

[%inc src/counter_demo.gleam mark=console_demo %]

-   The demo runs without a browser to confirm the model-update-view logic in isolation
-   `init()` creates a `Model(count: 0)`
-   After two increments and one decrement, `model.count` is `1`
-   `view(model)` returns `"Count: +1 (click + or - to change)"`

## Running in the Browser

-   To run in the browser:
    1.  Add `lustre` to `gleam.toml` dependencies
    2.  Set `target = "javascript"` in `gleam.toml`
    3.  Replace the console `view` with an HTML `view` returning `Element(Msg)`
    4.  Call `lustre.simple(init, update, view)` in `main`

[%inc snippets/browser.gleam mark=main_fn %]

-   `"#app"` is the CSS selector for the DOM element Lustre [%g mount "mounts" %] into

## Handling Forms

-   A more complex model adds an input field and a list of items:

[%inc snippets/browser.gleam mark=form_types %]

-   `InputChanged(String)` fires on every keystroke
    -   `update` stores the new string in `model.input`
-   `AddItem` moves `model.input` into `model.items` and clears the input
-   The `view` renders an `<input>` with `event.on_input(InputChanged)`
    and an `Add` button with `event.on_click(AddItem)`
-   This pattern extends to any form
    -   Bind each field to a `Msg` variant
    -   Store it in the model
    -   Submit on a button click

## Connecting to an API

-   Lustre effects run IO outside the pure `update` function:

[%inc snippets/effects.gleam mark=fetch_todos_fn %]

-   `effect.from` wraps an IO action;
    the `dispatch` callback sends a `Msg` back when the action completes
-   `update` returns `#(Model, Effect(Msg))` when effects are used
-   The runtime runs the effect after rendering
-   This keeps the model and update function pure:
    side effects are explicitly separated

## Testing

[%inc test/lustre_test.gleam mark=tests %]

-   The `update` function is pure, so testing it requires no browser
-   `increment_test` chains two increments and checks `model.count`
-   `decrement_test` confirms decrement goes negative
-   `reset_test` confirms `Reset` always returns count to 0

## Check Understanding

<details markdown="1">
<summary markdown="1">How is this different from React?</summary>

React manages state with hooks (`useState`, `useReducer`) inside components.
State updates trigger re-renders,
but the order of updates and renders can be surprising
when multiple state changes happen at once.

Lustre has one model for the whole application.
Every event produces exactly one call to `update`,
which returns one new model.
The runtime renders once after each update.
There are no hooks, no component-local state, and no effect order surprises.
The tradeoff is that Lustre applications require more up-front type design
(the `Msg` type must cover every event),
but the result is easier to test and reason about.

</details>

<details markdown="1">
<summary markdown="1">Why does `view` return `Element(Msg)` rather than a raw HTML string?</summary>

A typed virtual DOM catches errors the browser would silently ignore.
If `view` could produce any HTML string, you could accidentally fire an event
that is not a valid `Msg`, and `update` would have no case for it.
By parameterising `Element` on the message type,
the compiler verifies that every event handler in the view
produces a value that `update` knows how to handle.
This makes adding a new button a type-checked operation,
not a runtime surprise.

</details>

## Exercises

<div class="exercise" markdown="1">

### Reset button in view (10 minutes)

Add a `Reset` button to the HTML view.
The button should call `event.on_click(Reset)` and display `"reset"`.
Test by calling `update(model, Reset)` and confirming the count is 0.

</div>

<div class="exercise" markdown="1">

### Disable add button (15 minutes)

Add `InputChanged(String)` and `AddItem` to `Msg`.
In `view`, disable the Add button (using `attribute.disabled(True)`) when `model.input == ""`.
Write update tests confirming that `InputChanged` stores the value
and `AddItem` appends to the list and clears the input.

</div>

<div class="exercise" markdown="1">

### Colour by sign (10 minutes)

In `view`, give the count paragraph a CSS class based on its sign:
`"positive"` for `> 0`, `"negative"` for `< 0`, `"zero"` for `== 0`.
Use `attribute.class(...)`.
No runtime changes are needed;
write a test that the correct class string is produced for each sign.

</div>

<div class="exercise" markdown="1">

### Fetch on load (25 minutes)

Add `TodosLoaded(List(String))` to `Msg` and a `todos: List(String)` field to `Model`.
Write a `fetch_todos()` effect using `lustre/effect.from` and `gleam_httpc`
that calls `GET /todos` and dispatches `TodosLoaded`.
Dispatch the effect from `init`.

</div>
