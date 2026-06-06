import gleam/float
import gleam/int
import gleam/io

// mccole: arithmetic
pub fn main() {
  let sum = 2 + 2
  io.println(int.to_string(sum))

  let product = 6 * 7
  io.println(int.to_string(product))

  let float_div = int.to_float(10) /. int.to_float(3)
  io.println(float.to_string(float_div))
}
// mccole: /arithmetic
