import clock_demo.{dominates, merge_clocks}
import gleam/dict
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn merge_takes_max_test() {
  let a = dict.from_list([#("n1", 3), #("n2", 1)])
  let b = dict.from_list([#("n1", 1), #("n2", 4)])
  let merged = merge_clocks(a, b)
  dict.get(merged, "n1")
  |> should.equal(Ok(3))
  dict.get(merged, "n2")
  |> should.equal(Ok(4))
}

pub fn dominates_true_test() {
  let a = dict.from_list([#("n1", 2)])
  let b = dict.from_list([#("n1", 1)])
  dominates(a, b)
  |> should.be_true()
}

pub fn dominates_false_test() {
  let a = dict.from_list([#("n1", 1)])
  let b = dict.from_list([#("n1", 2)])
  dominates(a, b)
  |> should.be_false()
}

pub fn concurrent_test() {
  let a = dict.from_list([#("n1", 2), #("n2", 1)])
  let b = dict.from_list([#("n1", 1), #("n2", 3)])
  dominates(a, b)
  |> should.be_false()
  dominates(b, a)
  |> should.be_false()
}
// mccole: /tests

pub fn merged_dominates_both_test() {
  let a = dict.from_list([#("n1", 2)])
  let b = dict.from_list([#("n1", 1), #("n2", 3)])
  let merged = merge_clocks(a, b)
  dominates(merged, a)
  |> should.be_true()
  dominates(merged, b)
  |> should.be_true()
}
