import gleam/int
import gleam/io
import gleam/string

// mccole: main
pub fn main() {
  io.println(string.inspect(parse_int("42")))
  io.println(string.inspect(parse_int("not a number")))

  io.println(string.inspect(safe_divide(10, 2)))
  io.println(string.inspect(safe_divide(10, 0)))
}
// mccole: /main

// mccole: parse_fn
fn parse_int(s: String) -> Result(Int, String) {
  case int.parse(s) {
    Ok(n) -> Ok(n)
    Error(_) -> Error("not an integer: " <> s)
  }
}

// mccole: /parse_fn

// mccole: divide_fn
fn safe_divide(a: Int, b: Int) -> Result(Int, String) {
  case b {
    0 -> Error("division by zero")
    _ -> Ok(a / b)
  }
}
// mccole: /divide_fn
