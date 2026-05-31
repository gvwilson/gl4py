import gleam/io
import gleam/json
import gleam/list
import gleam/string

// mccole: todo_types
pub type Todo {
  Todo(id: Int, title: String, done: Bool)
}

pub type Msg {
  GetAll
  Add(String)
  MarkDone(Int)
  Remove(Int)
}
// mccole: /todo_types

pub fn main() {
  io.println("running Todo API simulation")

  let state = []

  let #(item, s1) = add(state, "learn Gleam")
  let #(_, s2) = add(s1, "build web API")
  io.println(string.inspect(get_all(s2)))

  let s3 = mark_done(s2, item.id)
  io.println(string.inspect(get_all(s3)))

  let s4 = remove(s3, 1)
  io.println(string.inspect(get_all(s4)))

  io.println("JSON encoding:")
  let encoded = encode_todos(get_all(s4))
  io.println(string.inspect(encoded))
}

// mccole: logic_fns
pub fn add(
  todos: List(Todo),
  title: String,
) -> #(Todo, List(Todo)) {
  let id = list.length(todos)
  let item = Todo(id, title, False)
  #(item, [item, ..todos])
}

pub fn get_all(todos: List(Todo)) -> List(Todo) {
  todos
}

pub fn mark_done(
  todos: List(Todo),
  id: Int,
) -> List(Todo) {
  list.map(todos, fn(t) {
    case t.id == id {
      True -> Todo(t.id, t.title, True)
      False -> t
    }
  })
}

pub fn remove(todos: List(Todo), id: Int) -> List(Todo) {
  list.filter(todos, fn(t) { t.id != id })
}
// mccole: /logic_fns

// mccole: encode_fn
fn encode_todos(todos: List(Todo)) -> String {
  json.array(todos, fn(t) {
    json.object([
      #("id", json.int(t.id)),
      #("title", json.string(t.title)),
      #("done", json.bool(t.done)),
    ])
  })
  |> json.to_string
}
// mccole: /encode_fn
