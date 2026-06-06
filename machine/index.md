# State Machines

<div class="callout" markdown="1">

-   A finite state machine models a system as a fixed set of states
    and a function that maps (state, event) pairs to the next state.
-   Representing states and events as custom types lets the compiler check
    that every case is handled.
-   The transition function returns `Result(State, String)` to reject invalid
    event sequences at runtime.
-   A recursive `run` function applies a list of events one at a time,
    stopping on the first error.

</div>

## Why State Machines?

-   Every time a browser sends an HTTP request,
    the server processes it through a fixed sequence of steps:
    -   Read the incoming bytes
    -   Match the URL to a handler
    -   Run that handler
    -   Write a response back
-   An experienced developer holds this picture in their head;
    a [%g finite_state_machine "finite state machine" %] puts it in the code
-   The core idea:
    -   a fixed set of states the system can be in
    -   a fixed set of events that can arrive
    -   a transition function that says "if I am in state S and event E arrives,
        move to state N"
-   Any event that has no entry in the table for the current state is invalid,
    which is how the machine enforces legal behavior
-   State machines appear everywhere:
    [%g tcp "TCP" %] connection handling,
    UI workflow steps,
    and characters in video games

## The States and Events

-   An HTTP request lifecycle has six states:

[%inc src/machine_demo.gleam mark=types %]

-   `Idle` waits for a new connection
-   `Reading` receives incoming bytes from the network
-   `Routing` matches the request path to a registered handler
-   `Handling` runs the application code for that handler
-   `Sending` writes the response bytes back to the client
-   `Done` signals that the response was delivered
-   The events that drive those transitions:
    -   `Connect`: a new TCP connection arrives
    -   `Data(String)`: the request line (method and path) has been read
    -   `Match(String)`: a route handler was found for the path
    -   `NoMatch`: no handler matched (the server will return 404)
    -   `Response(Int)`: the handler finished with an HTTP status code
    -   `Sent`: all response bytes were flushed to the network
-   Carrying data inside event variants (`Data`, `Match`, `Response`)
    lets callers attach context even if the transition function ignores it
    for the purpose of deciding which state comes next

## The Transition Function

[%inc src/machine_demo.gleam mark=step_fn %]

-   `case state, event` matches on both values simultaneously
    without wrapping them in a tuple
-   Each valid pair maps to `Ok(next_state)`; everything else maps to
    an `Error` carrying a message
-   `string.inspect` renders the state and event without a custom formatter
-   Only six transitions are valid; the `_, _` arm rejects all other combinations
-   This is the complete rule table of the machine,
    written as a single pattern match

## Running a Sequence of Events

[%inc src/machine_demo.gleam mark=run_fn %]

-   `run` applies a list of events to a starting state,
    returning the final state or the first error
-   Base case: no events remain, so the current state is the result
-   Recursive case: apply `step` to the first event;
    if it fails, return the error immediately;
    otherwise recurse with the new state and the remaining events
-   Once a bad event arrives, no further events are processed

## The Happy Path and the 404 Path

[%inc src/machine_demo.gleam mark=main_example %]

-   The happy path moves through all six states:
    `Idle → Reading → Routing → Handling → Sending → Done`
-   The [%g http_404 "404" %] path skips `Handling` entirely:
    `NoMatch` transitions directly from `Routing` to `Sending`,
    because there is no handler to run
-   Both paths end at `Ok(Done)`
-   The bad path tries `Sent` while still in `Reading`,
    which is nonsense, and gets an `Error` explaining exactly what went wrong

## Testing

[%inc test/machine_test.gleam mark=tests %]

-   Each single-step test calls `step` directly with one state and one event
-   `let assert Ok(Reading) = result` verifies the exact next state
-   `let assert Error(_) = result` checks that an invalid transition is rejected
    without caring about the error message text
-   The `run` tests verify complete event sequences,
    which is closer to how the machine is actually used in production

## Check Understanding

<details markdown="1">
<summary markdown="1">Why does `step` return `Result(State, String)` rather than just `State`?</summary>

A real server can receive malformed or out-of-order events:
a client might drop the connection mid-request,
or a bug might deliver the wrong event at the wrong time.
Returning `Result` forces the caller to decide what to do when an invalid event arrives.
If `step` returned a bare `State`, the only options would be to panic,
silently stay in the current state, or add a sentinel state like `Crashed`.
`Result` keeps the transition function pure
and lets the caller handle the failure in whatever way makes sense for its context.

</details>

<details markdown="1">
<summary markdown="1">What happens to events after an invalid transition in the list passed to `run`?</summary>

They are never processed.
`run` stops immediately and returns the `Error` from `step`.
This is the short-circuit behavior in the recursive case:
when `step` returns `Error(msg)`, the function returns `Error(msg)`
without recursing further.
The final valid state reached just before the error is also lost;
a caller that needs to recover it would have to change `run`
to return both the last valid state and the error message.

</details>

## Exercises

<div class="exercise" markdown="1">

### Trace transitions (10 minutes)

Write `trace(initial: State, events: List(Event)) -> List(String)`
that returns one human-readable string per successful transition,
formatted as `"Idle --Connect--> Reading"`.
Stop without adding an entry when an invalid event is encountered.

</div>

<div class="exercise" markdown="1">

### Reset event (15 minutes)

Add `Reset` to `Event`.
`step` should accept `Reset` from any state and return `Ok(Idle)`.
Write at least three tests:
one that resets from `Handling`,
one from `Sending`,
and one confirming that `run` handles a reset in the middle of a longer event list
and that the events following the reset proceed correctly from `Idle`.

</div>

<div class="exercise" markdown="1">

### Valid events (15 minutes)

Write `valid_events(state: State) -> List(Event)` that returns every event
that produces `Ok` from the given state.
Do not call `step` inside the function; enumerate the transitions directly.
Write one test per state confirming that every event in the returned list
really does produce `Ok` from that state,
and that `valid_events(Idle)` does not include `Sent` or `Response(0)`.

</div>

<div class="exercise" markdown="1">

### HTTP keepalive (20 minutes)

In HTTP/1.1, a connection can serve multiple requests without reconnecting.
Modify `step` so that `Done + Data(_) -> Ok(Routing)`,
skipping `Reading` since the TCP connection is already open.
Write two tests:
one showing a two-request keepalive sequence that ends at `Done` after both requests,
and one confirming that `Done + Connect` still returns `Error`.

</div>
