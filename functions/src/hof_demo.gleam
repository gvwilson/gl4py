import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn main() {
  // mccole: hof_demo
  let nums = [1, 2, 3, 4, 5]
  let doubled = list.map(nums, fn(x) { x * 2 })
  let evens = list.filter(nums, fn(x) { x % 2 == 0 })
  let total = list.fold(nums, 0, fn(acc, x) { acc + x })
  io.println("doubled: " <> string.inspect(doubled))
  io.println("evens: " <> string.inspect(evens))
  io.println("total: " <> int.to_string(total))
  // mccole: /hof_demo
}
