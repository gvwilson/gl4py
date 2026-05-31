import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/string

pub fn main() {
  io.println(string.inspect(option_inspect(Some(42))))
  io.println(string.inspect(option_inspect(None)))

  io.println(string.inspect(result_to_option(Ok(99))))
  io.println(string.inspect(result_to_option(Error("fail"))))

  io.println(string.inspect(first_positive([-1, 3, 0])))
  io.println(string.inspect(first_positive([-1, -2, -3])))
}

// mccole: option_case
fn option_inspect(opt: Option(Int)) -> String {
  case opt {
    Some(n) -> "got " <> int.to_string(n)
    None -> "nothing"
  }
}
// mccole: /option_case

fn result_to_option(r: Result(a, b)) -> Option(a) {
  case r {
    Ok(x) -> Some(x)
    Error(_) -> None
  }
}

// mccole: first_pos
fn first_positive(nums: List(Int)) -> Option(Int) {
  case nums {
    [] -> None
    [x, .._rest] if x > 0 -> Some(x)
    [_, ..rest] -> first_positive(rest)
  }
}
// mccole: /first_pos
