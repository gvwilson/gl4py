import gleam/io
import gleam/list
import gleam/string

pub type Elem {
  Literal(String)
  AnyChar
  Wildcard
}

pub fn main() {
  let files = [
    "main.gleam",
    "util.gleam",
    "data1.csv",
    "data2.csv",
    "notes.txt",
  ]
  io.println("*.gleam: " <> string.inspect(filter_files("*.gleam", files)))
  io.println("data?.csv: " <> string.inspect(filter_files("data?.csv", files)))
}

// mccole: filter_fn
pub fn filter_files(pattern: String, files: List(String)) -> List(String) {
  let elems = parse_pattern(pattern)
  list.filter(files, match_pattern(elems, _))
}

// mccole: /filter_fn

fn parse_pattern(s: String) -> List(Elem) {
  parse_chars(string.to_graphemes(s), [])
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

fn match_pattern(pattern: List(Elem), text: String) -> Bool {
  match_pattern_chars(pattern, string.to_graphemes(text))
}

fn match_pattern_chars(pattern: List(Elem), chars: List(String)) -> Bool {
  case pattern, chars {
    [], [] -> True
    [], _ -> False
    [Literal(c), ..pat_rest], _ ->
      case drop_prefix(string.to_graphemes(c), chars) {
        Ok(remaining) -> match_pattern_chars(pat_rest, remaining)
        Error(_) -> False
      }
    [AnyChar, ..pat_rest], [_, ..char_rest] ->
      match_pattern_chars(pat_rest, char_rest)
    [Wildcard, ..pat_rest], _ -> {
      case match_pattern_chars(pat_rest, chars) {
        True -> True
        False -> {
          case chars {
            [] -> False
            [_, ..char_rest] -> match_pattern_chars(pattern, char_rest)
          }
        }
      }
    }
    _, _ -> False
  }
}

fn drop_prefix(
  prefix: List(String),
  chars: List(String),
) -> Result(List(String), Nil) {
  case prefix, chars {
    [], remaining -> Ok(remaining)
    [p, ..pat_rest], [c, ..char_rest] if p == c ->
      drop_prefix(pat_rest, char_rest)
    _, _ -> Error(Nil)
  }
}
