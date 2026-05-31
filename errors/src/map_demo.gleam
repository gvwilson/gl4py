import gleam/io
import gleam/result
import gleam/string

pub fn main() {
  // mccole: map_usage
  io.println(string.inspect(ok_int(42) |> result.map(fn(x) { x + 1 })))
  io.println(string.inspect(error_str("oops") |> result.map(fn(x) { x + 1 })))
  // mccole: /map_usage
}

fn ok_int(n: Int) -> Result(Int, String) {
  Ok(n)
}

fn error_str(e: String) -> Result(Int, String) {
  Error(e)
}
