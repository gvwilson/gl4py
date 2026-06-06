import gleam/io
import gleam/list
import gleam/string

type Elem {
  Literal(String)
  AnyChar
  Wildcard
}

pub fn main() {
  let p1 = parse_pattern("*.gleam")
  io.println(string.inspect(p1))

  let p2 = parse_pattern("data?.csv")
  io.println(string.inspect(p2))

  let p3 = parse_pattern("hello")
  io.println(string.inspect(p3))
}

// mccole: parse_fn
fn parse_pattern(s: String) -> List(Elem) {
  let chars = string.to_graphemes(s)
  parse_chars(chars, [])
}

fn parse_chars(chars: List(String), acc: List(Elem)) -> List(Elem) {
  case chars {
    [] -> list.reverse(acc)
    ["*", ..rest] -> parse_chars(rest, [Wildcard, ..acc])
    ["?", ..rest] -> parse_chars(rest, [AnyChar, ..acc])
    _ -> {
      let #(literal, remaining) = take_literal(chars, [])
      parse_chars(remaining, [Literal(literal), ..acc])
    }
  }
}

// mccole: /parse_fn

fn take_literal(
  chars: List(String),
  acc: List(String),
) -> #(String, List(String)) {
  case chars {
    [] -> #(acc |> list.reverse |> string.join(""), [])
    ["*", ..] -> #(acc |> list.reverse |> string.join(""), chars)
    ["?", ..] -> #(acc |> list.reverse |> string.join(""), chars)
    [c, ..rest] -> take_literal(rest, [c, ..acc])
  }
}
