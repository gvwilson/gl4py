import gleam/int
import gleam/io
import gleam/result
import gleam/string

pub fn main() {
  // mccole: use_ok
  let ok_result = {
    use total <- result.try(parse_int("30"))
    use divisor <- result.try(parse_int("6"))
    use quotient <- result.try(safe_divide(total, divisor))
    validate_positive(quotient)
  }
  io.println(string.inspect(ok_result))
  // mccole: /use_ok

  // mccole: use_err
  let err_result = {
    use total <- result.try(parse_int("30"))
    use divisor <- result.try(parse_int("0"))
    use quotient <- result.try(safe_divide(total, divisor))
    validate_positive(quotient)
  }
  io.println(string.inspect(err_result))
  // mccole: /use_err
}

fn parse_int(s: String) -> Result(Int, String) {
  case int.parse(s) {
    Ok(n) -> Ok(n)
    Error(_) -> Error("not an integer: " <> s)
  }
}

fn safe_divide(numerator: Int, denominator: Int) -> Result(Int, String) {
  case denominator {
    0 -> Error("division by zero")
    _ -> Ok(numerator / denominator)
  }
}

fn validate_positive(n: Int) -> Result(Int, String) {
  case n > 0 {
    True -> Ok(n)
    False -> Error("expected a positive number, got " <> int.to_string(n))
  }
}
