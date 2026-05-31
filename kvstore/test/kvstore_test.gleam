import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import log_demo.{Delete, Set, get}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn set_and_get_test() {
  let log = [Set("x", "1")]
  get(log, "x")
  |> should.equal(Some("1"))
}

pub fn overwrite_test() {
  // newest entry is prepended; Set("x","2") is the most recent write
  let log = [Set("x", "2"), Set("x", "1")]
  get(log, "x")
  |> should.equal(Some("2"))
}

pub fn delete_test() {
  // Delete is prepended after Set, so it is the most recent entry
  let log = [Delete("x"), Set("x", "1")]
  get(log, "x")
  |> should.equal(None)
}
// mccole: /tests
