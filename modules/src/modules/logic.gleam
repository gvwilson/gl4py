import gleam/int
import gleam/list
import gleam/string
import modules/types

// mccole: add_task
pub fn add_task(tasks: List(types.Todo), title: String) -> List(types.Todo) {
  [types.Todo(title, types.Active), ..tasks]
}
// mccole: /add_task

pub fn mark_done(tasks: List(types.Todo), index: Int) -> List(types.Todo) {
  tasks
  |> list.index_map(fn(task, i) {
    case i == index {
      True -> types.Todo(task.title, types.Done)
      False -> task
    }
  })
}

pub fn list_tasks(tasks: List(types.Todo)) -> List(types.Todo) {
  tasks
}

// mccole: render
pub fn render(tasks: List(types.Todo)) -> String {
  tasks
  |> list.index_map(fn(task, i) {
    let num = int.to_string(i + 1) <> ". "
    let status = types.display_status(task.status)
    num <> status <> " " <> task.title
  })
  |> string.join("\n")
}
// mccole: /render
