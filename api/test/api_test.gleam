import gleam/list
import gleeunit
import gleeunit/should
import todo_server.{Todo, add, mark_done, remove}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn add_creates_item_test() {
  let #(item, todos) = add([], "learn Gleam")
  item.title
  |> should.equal("learn Gleam")
  item.done
  |> should.be_false()
  list.length(todos)
  |> should.equal(1)
}

pub fn mark_done_updates_flag_test() {
  let #(_, todos) = add([], "task")
  let updated = mark_done(todos, 0)
  list.first(updated)
  |> should.equal(Ok(Todo(0, "task", True)))
}

pub fn remove_deletes_item_test() {
  let #(_, todos) = add([], "task")
  remove(todos, 0)
  |> list.length
  |> should.equal(0)
}
// mccole: /tests
