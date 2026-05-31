// mccole: status_todo
pub type Status {
  Active
  Done
}

pub type Todo {
  Todo(title: String, status: Status)
}
// mccole: /status_todo

// mccole: display_status
pub fn display_status(status: Status) -> String {
  case status {
    Active -> "[ ]"
    Done -> "[x]"
  }
}
// mccole: /display_status
