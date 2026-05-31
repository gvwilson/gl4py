import gleam/list
import gleeunit
import gleeunit/should
import todo_db.{create_table, delete_todo, get_all, insert_todo, mark_done}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn insert_and_get_test() {
  let db = create_table()
  let db = insert_todo(db, "write tests")
  get_all(db)
  |> list.length
  |> should.equal(1)
}

pub fn mark_done_test() {
  let db = create_table()
  let db = insert_todo(db, "finish docs")
  let db = mark_done(db, 0)
  get_all(db)
  |> list.first
  |> should.be_ok
  |> fn(t) { t.done }
  |> should.be_true()
}

pub fn delete_test() {
  let db = create_table()
  let db = insert_todo(db, "clean up")
  delete_todo(db, 0)
  |> get_all
  |> should.equal([])
}
// mccole: /tests
