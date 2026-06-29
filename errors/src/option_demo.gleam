import gleam/int
import gleam/io
import gleam/option
import gleam/string

// mccole: main
pub fn main() {
  io.println(string.inspect(option_inspect(option.Some(42))))
  io.println(string.inspect(option_inspect(option.None)))

  io.println(string.inspect(result_to_option(Ok(99))))
  io.println(string.inspect(result_to_option(Error("fail"))))

  io.println(string.inspect(first_positive([-1, 3, 0])))
  io.println(string.inspect(first_positive([-1, -2, -3])))
}
// mccole: /main

// mccole: option_case
fn option_inspect(opt: option.Option(Int)) -> String {
  case opt {
    option.Some(n) -> "got " <> int.to_string(n)
    option.None -> "nothing"
  }
}

// mccole: /option_case

fn result_to_option(r: Result(a, b)) -> option.Option(a) {
  case r {
    Ok(x) -> option.Some(x)
    Error(_) -> option.None
  }
}

// mccole: first_pos
fn first_positive(nums: List(Int)) -> option.Option(Int) {
  case nums {
    [] -> option.None
    [x, ..] if x > 0 -> option.Some(x)
    [_, ..rest] -> first_positive(rest)
  }
}
// mccole: /first_pos
