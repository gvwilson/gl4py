import gleeunit
import gleeunit/should
import machine_demo.{
  Connect, Data, Done, Handling, Idle, Match, NoMatch, Reading, Response,
  Routing, Sending, Sent, run, step,
}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn idle_connect_test() {
  step(Idle, Connect)
  |> should.equal(Ok(Reading))
}

pub fn reading_data_test() {
  step(Reading, Data("GET /users"))
  |> should.equal(Ok(Routing))
}

pub fn routing_match_test() {
  step(Routing, Match("users_handler"))
  |> should.equal(Ok(Handling))
}

pub fn routing_not_found_test() {
  step(Routing, NoMatch)
  |> should.equal(Ok(Sending))
}

pub fn handling_response_test() {
  step(Handling, Response(200))
  |> should.equal(Ok(Sending))
}

pub fn sending_sent_test() {
  step(Sending, Sent)
  |> should.equal(Ok(Done))
}

pub fn invalid_transition_test() {
  step(Idle, Sent)
  |> should.be_error()
}

// mccole: /tests

pub fn happy_path_test() {
  let events = [
    Connect,
    Data("GET /users"),
    Match("users_handler"),
    Response(200),
    Sent,
  ]
  run(Idle, events)
  |> should.equal(Ok(Done))
}

pub fn not_found_path_test() {
  let events = [Connect, Data("GET /nope"), NoMatch, Sent]
  run(Idle, events)
  |> should.equal(Ok(Done))
}

pub fn stops_on_error_test() {
  let events = [Connect, Sent]
  run(Idle, events)
  |> should.be_error()
}
