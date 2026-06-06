import gleam/int
import gleam/io

pub fn main() {
  // mccole: assert_demo
  let assert Ok(n) = int.parse("42")
  io.println("parsed: " <> int.to_string(n))
  // mccole: /assert_demo
}
