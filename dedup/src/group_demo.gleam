import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  let files = [
    #("/a/one.txt", "hello world"),
    #("/b/two.txt", "foo bar"),
    #("/c/three.txt", "hello world"),
    #("/d/four.txt", "baz qux"),
    #("/e/five.txt", "hello world"),
    #("/f/six.txt", "foo bar"),
  ]

  let groups = group_by_hash(files)
  io.println(groups |> dict.size() |> int.to_string)
  io.println("---")

  let dups = find_duplicates(files)
  io.println(string.inspect(dups))
  io.println("---")

  io.println(report_duplicates(dups))
}

// In production, use a cryptographic hash (e.g. SHA-256).
// Here the content itself serves as its own key to keep the example self-contained.
fn hash_content(content: String) -> String {
  content
}

// mccole: group_fn
fn group_by_hash(
  files: List(#(String, String)),
) -> dict.Dict(String, List(String)) {
  list.fold(files, dict.new(), fn(acc, file) {
    let #(path, content) = file
    let hash = hash_content(content)
    let existing = dict.get(acc, hash) |> result.unwrap([])
    dict.insert(acc, hash, [path, ..existing])
  })
}

// mccole: /group_fn

// mccole: find_fn
pub fn find_duplicates(files: List(#(String, String))) -> List(List(String)) {
  files
  |> group_by_hash
  |> dict.values
  |> list.filter(fn(paths) { list.length(paths) > 1 })
}

// mccole: /find_fn

// mccole: report_fn
fn report_duplicates(groups: List(List(String))) -> String {
  case groups {
    [] -> "no duplicates found"
    _ -> {
      let count = groups |> list.length |> int.to_string
      count <> " duplicate group(s) found"
    }
  }
}
// mccole: /report_fn
