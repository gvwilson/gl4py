import gleam/int
import gleam/io
import gleam/result
import gleam/string

pub fn main() {
  // mccole: use_success
  let result = {
    use x <- result.try(parse_int("10"))
    use y <- result.try(parse_int("20"))
    use z <- result.try(safe_divide(x + y, 3))
    Ok(z * 2)
  }
  io.println(string.inspect(result))
  // mccole: /use_success

  // mccole: use_fail
  let fail = {
    use x <- result.try(parse_int("10"))
    use y <- result.try(parse_int("bad"))
    use z <- result.try(safe_divide(x + y, 3))
    Ok(z * 2)
  }
  io.println(string.inspect(fail))
  // mccole: /use_fail
}

fn parse_int(s: String) -> Result(Int, String) {
  case int.parse(s) {
    Ok(n) -> Ok(n)
    Error(_) -> Error("not an integer: " <> s)
  }
}

fn safe_divide(a: Int, b: Int) -> Result(Int, String) {
  case b {
    0 -> Error("division by zero")
    _ -> Ok(a / b)
  }
}
