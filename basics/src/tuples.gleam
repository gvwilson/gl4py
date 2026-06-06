import gleam/bool
import gleam/int
import gleam/io
import gleam/string

pub fn main() {
  // mccole: tuple_create
  let t = #(1, "hello", True)
  io.println(string.inspect(t))
  // mccole: /tuple_create

  // mccole: tuple_destruct
  let #(a, b, c) = t
  io.println("a from tuple is " <> int.to_string(a))
  io.println("b from tuple is " <> string.inspect(b))
  io.println("c from tuple is " <> bool.to_string(c))
  // mccole: /tuple_destruct
}
