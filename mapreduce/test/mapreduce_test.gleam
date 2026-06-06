import gleam/dict
import gleeunit
import gleeunit/should
import wordcount_demo.{extension_count, word_count}

pub fn main() {
  gleeunit.main()
}

// mccole: word_count_test
pub fn word_count_basic_test() {
  let words = ["a", "b", "a", "c", "b", "a"]
  let result = word_count(words)
  dict.get(result, "a")
  |> should.equal(Ok(3))
  dict.get(result, "b")
  |> should.equal(Ok(2))
  dict.get(result, "c")
  |> should.equal(Ok(1))
}

// mccole: /word_count_test

pub fn word_count_empty_test() {
  word_count([])
  |> dict.size
  |> should.equal(0)
}

// mccole: extension_count_test
pub fn extension_count_test() {
  let files = ["a.gleam", "b.gleam", "c.md", "Makefile"]
  let result = extension_count(files)
  dict.get(result, "gleam")
  |> should.equal(Ok(2))
  dict.get(result, "md")
  |> should.equal(Ok(1))
  dict.get(result, "Makefile")
  |> should.be_error()
}
// mccole: /extension_count_test
