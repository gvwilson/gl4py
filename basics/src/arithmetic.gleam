import gleam/int
import gleam/io
import gleam/string

// mccole: arithmetic
pub fn main() {
  let sum = 2 + 2
  io.println(string.inspect(sum))

  let product = 6 * 7
  io.println(string.inspect(product))

  let float_div = int.to_float(10) /. int.to_float(3)
  io.println(string.inspect(float_div))
}
// mccole: /arithmetic
