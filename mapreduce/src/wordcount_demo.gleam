import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string

// mccole: mapresult_type
type MapResult(k, v) =
  List(#(k, v))
// mccole: /mapresult_type

pub fn main() {
  let text = "the quick brown fox jumps over the lazy dog"
  let words = string.split(text, " ")

  let counts = word_count(words)
  io.println(string.inspect(counts))

  let filenames = ["main.gleam", "utils.gleam", "Makefile"]
  let ext_counts = extension_count(filenames)
  io.println(string.inspect(ext_counts))
}

// mccole: word_count_fn
pub fn word_count(words: List(String)) -> dict.Dict(String, Int) {
  mapreduce(
    words,
    fn(w) { [#(w, 1)] },
    fn(_key, values) { list.fold(values, 0, fn(a, n) { a + n }) },
  )
}
// mccole: /word_count_fn

// mccole: extension_count_fn
pub fn extension_count(files: List(String)) -> dict.Dict(String, Int) {
  mapreduce(
    files,
    fn(f) {
      case string.split(f, ".") {
        [_, ext] -> [#(ext, 1)]
        _ -> []
      }
    },
    fn(_key, values) { list.fold(values, 0, fn(a, n) { a + n }) },
  )
}
// mccole: /extension_count_fn

// mccole: mapreduce_fn
fn mapreduce(
  inputs: List(elem),
  mapper: fn(elem) -> MapResult(key, val),
  reducer: fn(key, List(val)) -> val,
) -> dict.Dict(key, val) {
  let pairs = list.flat_map(inputs, mapper)
  let grouped = shuffle(pairs)
  dict.map_values(grouped, reducer)
}
// mccole: /mapreduce_fn

// mccole: shuffle_fn
fn shuffle(pairs: MapResult(key, val)) -> dict.Dict(key, List(val)) {
  list.fold(pairs, dict.new(), fn(acc, pair) {
    let #(k, v) = pair
    let existing = dict.get(acc, k) |> result.unwrap([])
    dict.insert(acc, k, [v, ..existing])
  })
}
// mccole: /shuffle_fn
