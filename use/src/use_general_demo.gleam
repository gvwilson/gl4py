import gleam/int
import gleam/io
import gleam/list

fn with_greeting(name: String, callback: fn(String) -> Nil) -> Nil {
  callback("Hello, " <> name <> "!")
}

pub fn main() {
  // mccole: callback_long
  with_greeting("Gleam", fn(greeting) { io.println(greeting) })
  // mccole: /callback_long

  // mccole: callback_use
  {
    use greeting <- with_greeting("Gleam")
    io.println(greeting)
  }
  // mccole: /callback_use

  // mccole: list_each
  {
    use item <- list.each([1, 2, 3])
    io.println(int.to_string(item))
  }
  // mccole: /list_each
}
