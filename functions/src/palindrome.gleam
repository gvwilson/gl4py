import gleam/bool
import gleam/io
import gleam/list
import gleam/string

pub fn main() {
  io.println(
    "'racecar' is palindrome: " <> bool.to_string(is_palindrome("racecar")),
  )
  io.println(
    "'gleam' is palindrome: " <> bool.to_string(is_palindrome("gleam")),
  )
}

// mccole: palindrome
fn is_palindrome(s: String) -> Bool {
  let chars = string.to_graphemes(s)
  chars == list.reverse(chars)
}
// mccole: /palindrome
