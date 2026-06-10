import gleam/io
import utils/logic
import utils/types

pub fn main() {
  let tasks = [
    types.Todo("learn Gleam", types.Active),
    types.Todo("build project", types.Done),
    types.Todo("write tests", types.Active),
  ]

  let added = logic.add_task(tasks, "ship code")
  let completed = logic.mark_done(added, 1)

  logic.list_tasks(completed)
  |> logic.render
  |> io.println
}
