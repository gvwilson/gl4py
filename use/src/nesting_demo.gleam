import gleam/int
import gleam/io
import gleam/string

pub fn main() {
  // mccole: nested_ok
  let ok_result = case parse_int("30") {
    Error(reason) -> Error(reason)
    Ok(total) ->
      case parse_int("6") {
        Error(reason) -> Error(reason)
        Ok(divisor) ->
          case safe_divide(total, divisor) {
            Error(reason) -> Error(reason)
            Ok(quotient) -> validate_positive(quotient)
          }
      }
  }
  io.println(string.inspect(ok_result))
  // mccole: /nested_ok

  // mccole: nested_err
  let err_result = case parse_int("30") {
    Error(reason) -> Error(reason)
    Ok(total) ->
      case parse_int("0") {
        Error(reason) -> Error(reason)
        Ok(divisor) ->
          case safe_divide(total, divisor) {
            Error(reason) -> Error(reason)
            Ok(quotient) -> validate_positive(quotient)
          }
      }
  }
  io.println(string.inspect(err_result))
  // mccole: /nested_err
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
