import gleam/io
import gleam/string

// mccole: types
pub type State {
  Idle
  Reading
  Routing
  Handling
  Sending
  Done
}

pub type Event {
  Connect
  Data(String)
  Match(String)
  NoMatch
  Response(Int)
  Sent
}

// mccole: /types

// mccole: step_fn
pub fn step(state: State, event: Event) -> Result(State, String) {
  case state, event {
    Idle, Connect -> Ok(Reading)
    Reading, Data(_) -> Ok(Routing)
    Routing, Match(_) -> Ok(Handling)
    Routing, NoMatch -> Ok(Sending)
    Handling, Response(_) -> Ok(Sending)
    Sending, Sent -> Ok(Done)
    _, _ ->
      Error(
        "cannot handle "
        <> string.inspect(event)
        <> " in state "
        <> string.inspect(state),
      )
  }
}

// mccole: /step_fn

// mccole: run_fn
pub fn run(state: State, events: List(Event)) -> Result(State, String) {
  case events {
    [] -> Ok(state)
    [event, ..rest] ->
      case step(state, event) {
        Error(msg) -> Error(msg)
        Ok(next) -> run(next, rest)
      }
  }
}

// mccole: /run_fn

pub fn main() {
  // mccole: main_example
  let happy_path = [
    Connect,
    Data("GET /users"),
    Match("users_handler"),
    Response(200),
    Sent,
  ]
  io.println("Happy path: " <> string.inspect(run(Idle, happy_path)))

  let not_found = [Connect, Data("GET /nope"), NoMatch, Sent]
  io.println("Not found: " <> string.inspect(run(Idle, not_found)))

  let bad = [Connect, Sent]
  io.println("Bad event: " <> string.inspect(run(Idle, bad)))
  // mccole: /main_example
}
