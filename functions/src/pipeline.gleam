import gleam/int
import gleam/io
import gleam/list

pub fn main() {
  // mccole: pipeline
  let result =
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    |> list.map(fn(x) { x * 2 })
    |> list.filter(fn(x) { x > 10 })
    |> list.fold(0, fn(acc, x) { acc + x })

  io.println("pipeline result is " <> int.to_string(result))
  // mccole: /pipeline
}
