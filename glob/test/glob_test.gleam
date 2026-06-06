import gleeunit
import gleeunit/should
import match_demo.{AnyChar, Literal, Wildcard, match_pattern}

pub fn main() {
  gleeunit.main()
}

// mccole: examples
pub fn literal_match_test() {
  match_pattern([Literal("a")], "a")
  |> should.be_true()
}

pub fn anychar_test() {
  match_pattern([AnyChar], "x")
  |> should.be_true()
}

pub fn wildcard_many_test() {
  match_pattern([Wildcard, Literal(".gleam")], "mymodule.gleam")
  |> should.be_true()
}

// mccole: /examples

pub fn literal_no_match_test() {
  match_pattern([Literal("a")], "b")
  |> should.be_false()
}

pub fn anychar_empty_test() {
  match_pattern([AnyChar], "")
  |> should.be_false()
}

pub fn wildcard_zero_test() {
  match_pattern([Wildcard, Literal(".gleam")], ".gleam")
  |> should.be_true()
}

pub fn wildcard_no_match_test() {
  match_pattern([Wildcard, Literal(".gleam")], "mymodule.rs")
  |> should.be_false()
}

pub fn empty_pattern_empty_input_test() {
  match_pattern([], "")
  |> should.be_true()
}

pub fn empty_pattern_nonempty_input_test() {
  match_pattern([], "x")
  |> should.be_false()
}
