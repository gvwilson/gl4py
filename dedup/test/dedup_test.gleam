import gleam/list
import gleeunit
import gleeunit/should
import group_demo.{find_duplicates}

pub fn main() {
  gleeunit.main()
}

// mccole: examples
pub fn no_duplicates_test() {
  let files = [
    #("/a.txt", "aaa"),
    #("/b.txt", "bbb"),
    #("/c.txt", "ccc"),
  ]
  find_duplicates(files)
  |> should.equal([])
}

pub fn one_group_test() {
  let files = [
    #("/a.txt", "abc"),
    #("/b.txt", "def"),
    #("/c.txt", "abc"),
  ]
  let groups = find_duplicates(files)
  list.length(groups)
  |> should.equal(1)
}

pub fn three_copies_test() {
  let files = [
    #("/a.txt", "xyz"),
    #("/b.txt", "xyz"),
    #("/c.txt", "xyz"),
  ]
  let groups = find_duplicates(files)
  list.length(groups)
  |> should.equal(1)
  groups
  |> list.first
  |> should.be_ok
  |> list.length
  |> should.equal(3)
}
// mccole: /examples
