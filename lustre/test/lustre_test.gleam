import gleeunit
import gleeunit/should
import counter_demo.{Decrement, Increment, Reset, init, update}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn increment_test() {
  init()
  |> update(Increment)
  |> update(Increment)
  |> fn(m) { m.count }
  |> should.equal(2)
}

pub fn decrement_test() {
  init()
  |> update(Decrement)
  |> fn(m) { m.count }
  |> should.equal(-1)
}

pub fn reset_test() {
  let model = update(init(), Increment) |> update(Increment)
  update(model, Reset).count
  |> should.equal(0)
}
// mccole: /tests
