import gleam/bool
import gleam/io
import gleam/list
import gleam/string

// mccole: elem_type
pub type Elem {
  Literal(String)
  AnyChar
  Wildcard
}

// mccole: /elem_type

pub fn main() {
  list.each(["hello.gleam", "hello.rs", ".gleam"], fn(word) {
    try([Wildcard, Literal(".gleam")], word)
  })
  list.each(["dot", "dat", "dog"], fn(word) {
    try([Literal("d"), AnyChar, Literal("t")], word)
  })
}

fn try(pat: List(Elem), word: String) -> Bool {
  let result = match_pattern(pat, word)
  io.println(
    string.inspect(pat) <> " and '" <> word <> "' == " <> bool.to_string(result),
  )
  result
}

// mccole: match_fn
pub fn match_pattern(pattern: List(Elem), text: String) -> Bool {
  match_pattern_chars(pattern, string_to_chars(text))
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

// mccole: /match_fn

fn string_to_chars(s: String) -> List(String) {
  string.to_graphemes(s)
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
