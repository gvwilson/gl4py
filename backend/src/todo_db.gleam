import gleam/io
import gleam/list
import gleam/string

// mccole: db_type
pub type Todo {
  Todo(id: Int, title: String, done: Bool, created_at: Int)
}

pub type Database {
  Database(todos: List(Todo), next_id: Int)
}
// mccole: /db_type

pub fn main() {
  io.println("SQLite-backed Todo simulation")
  io.println("---")

  let db = create_table()

  let db = db |> insert_todo("learn Gleam")
  let db = db |> insert_todo("build API")
  let db = db |> insert_todo("write tests")

  io.println("all todos:")
  io.println(string.inspect(get_all(db)))

  let db = db |> mark_done(1)
  io.println("after marking id=1 done:")
  io.println(string.inspect(get_all(db)))

  let db = db |> delete_todo(0)
  io.println("after deleting id=0:")
  io.println(string.inspect(get_all(db)))

  io.println("open todos only:")
  io.println(string.inspect(get_open(db)))
}

pub fn create_table() -> Database {
  Database([], 0)
}

// mccole: crud_fns
pub fn insert_todo(db: Database, title: String) -> Database {
  let item = Todo(db.next_id, title, False, 0)
  Database([item, ..db.todos], db.next_id + 1)
}

pub fn get_all(db: Database) -> List(Todo) {
  db.todos
}

pub fn get_open(db: Database) -> List(Todo) {
  list.filter(db.todos, fn(t) { !t.done })
}

pub fn mark_done(db: Database, id: Int) -> Database {
  let new_todos =
    list.map(db.todos, fn(t) {
      case t.id == id {
        True -> Todo(t.id, t.title, True, t.created_at)
        False -> t
      }
    })
  Database(new_todos, db.next_id)
}

pub fn delete_todo(db: Database, id: Int) -> Database {
  Database(
    list.filter(db.todos, fn(t) { t.id != id }),
    db.next_id,
  )
}
// mccole: /crud_fns
