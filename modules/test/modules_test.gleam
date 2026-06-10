import gleeunit
import gleeunit/should
import utils/logic
import utils/types

pub fn main() {
  gleeunit.main()
}

// mccole: test_examples
pub fn add_task_test() {
  let result = logic.add_task([], "write tests")
  result
  |> should.equal([types.Todo("write tests", types.Active)])
}

pub fn render_single_test() {
  let tasks = [types.Todo("learn Gleam", types.Active)]
  logic.render(tasks)
  |> should.equal("1. [ ] learn Gleam")
}
// mccole: /test_examples
