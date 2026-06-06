import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

// mccole: entry_type
pub type Entry {
  Set(key: String, value: String)
  Delete(key: String)
}

// mccole: /entry_type

pub fn main() {
  let log = [
    Set("name", "Ada"),
    Set("lang", "Gleam"),
    Set("name", "Grace"),
    Delete("lang"),
  ]

  io.println(string.inspect(get(log, "name")))
  io.println(string.inspect(get(log, "lang")))
  io.println(string.inspect(get(log, "missing")))
  io.println("---")

  let live = keys(log)
  io.println(string.inspect(live))
  io.println("---")

  let compacted = compact(log)
  io.println(string.inspect(compacted))
}

// mccole: get_fn
pub fn get(log: List(Entry), key: String) -> Option(String) {
  get_scan(log, key)
}

fn get_scan(log: List(Entry), key: String) -> Option(String) {
  case log {
    [] -> None
    [Set(k, v), ..] if k == key -> Some(v)
    [Delete(k), ..] if k == key -> None
    [_, ..rest] -> get_scan(rest, key)
  }
}

// mccole: /get_fn

// mccole: keys_fn
pub fn keys(log: List(Entry)) -> List(String) {
  log
  |> list.fold(dict.new(), fn(acc, entry) {
    case entry {
      Set(k, _) -> dict.insert(acc, k, True)
      Delete(k) -> dict.delete(acc, k)
    }
  })
  |> dict.keys
}

// mccole: /keys_fn

// mccole: compact_fn
pub fn compact(log: List(Entry)) -> List(Entry) {
  let live_dict =
    list.fold(list.reverse(log), dict.new(), fn(acc, entry) {
      case entry {
        Set(k, v) -> dict.insert(acc, k, v)
        Delete(k) -> dict.delete(acc, k)
      }
    })

  dict.to_list(live_dict)
  |> list.map(fn(item) {
    let #(k, v) = item
    Set(k, v)
  })
}

// mccole: /compact_fn

// mccole: index_fns
pub fn build_index(log: List(Entry)) -> dict.Dict(String, String) {
  list.fold(list.reverse(log), dict.new(), fn(acc, entry) {
    case entry {
      Set(k, v) -> dict.insert(acc, k, v)
      Delete(k) -> dict.delete(acc, k)
    }
  })
}

pub fn get_indexed(
  index: dict.Dict(String, String),
  key: String,
) -> Option(String) {
  case dict.get(index, key) {
    Ok(v) -> Some(v)
    Error(_) -> None
  }
}
// mccole: /index_fns
