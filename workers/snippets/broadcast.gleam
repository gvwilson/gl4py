import gleam/list
import gleam/otp/actor
import gleam/otp/process

// mccole: broadcast_types
type Msg {
  Subscribe(process.Subject(String))
  Broadcast(String)
}
// mccole: /broadcast_types

// mccole: broadcast_handle
fn handle(
  msg: Msg,
  state: List(process.Subject(String)),
) -> actor.Next(List(process.Subject(String))) {
  case msg {
    Subscribe(sub) -> actor.Continue([sub, ..state])
    Broadcast(text) -> {
      list.each(state, fn(sub) { process.send(sub, text) })
      actor.Continue(state)
    }
  }
}
// mccole: /broadcast_handle
