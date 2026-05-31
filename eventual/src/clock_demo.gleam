import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/string

pub fn main() {
  let a = dict.new()
    |> dict.insert("n1", 1)
  let b = dict.new()
    |> dict.insert("n1", 2)
    |> dict.insert("n2", 1)

  io.println("clock a: " <> string.inspect(a))
  io.println("clock b: " <> string.inspect(b))

  let merged = merge_clocks(a, b)
  io.println("merged: " <> string.inspect(merged))

  io.println("a dominates b? " <> bool.to_string(dominates(a, b)))
  io.println("merged dominates a? " <> bool.to_string(dominates(merged, a)))
  io.println("merged dominates b? " <> bool.to_string(dominates(merged, b)))
}

// mccole: merge_fn
pub fn merge_clocks(
  a: dict.Dict(String, Int),
  b: dict.Dict(String, Int),
) -> dict.Dict(String, Int) {
  dict.combine(a, b, fn(va, vb) { int.max(va, vb) })
}
// mccole: /merge_fn

// mccole: dominates_fn
pub fn dominates(
  a: dict.Dict(String, Int),
  b: dict.Dict(String, Int),
) -> Bool {
  let a_entries = dict.to_list(a)
  list.all(a_entries, fn(entry) {
    let #(node, count_a) = entry
    let count_b = dict.get(b, node) |> result.unwrap(0)
    count_a >= count_b
  })
}
// mccole: /dominates_fn

// mccole: versioned_type
pub type Versioned(v) {
  Versioned(value: v, clock: dict.Dict(String, Int))
}
// mccole: /versioned_type

// mccole: resolve_fn
pub fn resolve(
  local: Versioned(String),
  remote: Versioned(String),
) -> Versioned(String) {
  let merged_clock = merge_clocks(local.clock, remote.clock)
  case dominates(local.clock, remote.clock) {
    True -> Versioned(local.value, merged_clock)
    False ->
      case dominates(remote.clock, local.clock) {
        True -> Versioned(remote.value, merged_clock)
        False ->
          case string.compare(local.value, remote.value) {
            order.Lt | order.Eq -> Versioned(local.value, merged_clock)
            order.Gt -> Versioned(remote.value, merged_clock)
          }
      }
  }
}
// mccole: /resolve_fn
