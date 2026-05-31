import gleam/io
import gleam/list
import gleam/string

type Entry {
  Set(key: String, value: String)
  Delete(key: String)
}

pub fn main() {
  let log = [
    Set("a", "1"),
    Set("b", "2"),
    Set("a", "3"),
    Delete("b"),
    Set("c", "4"),
  ]

  io.println(string.inspect(compact_to_lines(log)))

  let parsed = parse_lines(compact_to_lines(log))
  io.println(string.inspect(parsed))
}

// mccole: persist_fn
fn compact_to_lines(log: List(Entry)) -> List(String) {
  log
  |> list.map(fn(entry) {
    case entry {
      Set(k, v) -> "SET|" <> k <> "|" <> v
      Delete(k) -> "DEL|" <> k
    }
  })
}

fn parse_lines(lines: List(String)) -> List(Entry) {
  list.map(lines, fn(line) {
    case string.split(line, "|") {
      ["SET", k, v] -> Set(k, v)
      ["DEL", k] -> Delete(k)
      _ -> Set("error", "bad line")
    }
  })
}
// mccole: /persist_fn
