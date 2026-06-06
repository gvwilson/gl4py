import gleam/int
import gleam/io
import gleam/list
import gleam/string

// Number of characters per simulated chunk.
// A real implementation would read this many bytes from the file system.
const chunk_size = 32

// mccole: parse_fn
// Parse one CSV row, rejecting blank lines.
// Returns the fields as a list of strings; does not handle quoted commas.
pub fn parse_row(line: String) -> Result(List(String), String) {
  case string.trim(line) {
    "" -> Error("empty row")
    trimmed -> Ok(string.split(trimmed, ","))
  }
}

// mccole: /parse_fn

// mccole: fold_fn
// Fold over every non-blank row in a CSV string, line by line.
pub fn fold_rows(text: String, init: b, f: fn(b, List(String)) -> b) -> b {
  list.fold(string.split(text, "\n"), init, fn(acc, line) {
    case parse_row(line) {
      Error(_) -> acc
      Ok(fields) -> f(acc, fields)
    }
  })
}

// Like fold_rows but skips the first line (the header row).
pub fn fold_with_header(
  text: String,
  init: b,
  f: fn(b, List(String)) -> b,
) -> b {
  case string.split(text, "\n") {
    [] -> init
    [_] -> init
    [_, ..data_lines] ->
      list.fold(data_lines, init, fn(acc, line) {
        case parse_row(line) {
          Error(_) -> acc
          Ok(fields) -> f(acc, fields)
        }
      })
  }
}

// mccole: /fold_fn

// mccole: chunk_fn
// Split text into chunks of at most chunk_size characters,
// simulating reading a file in fixed-size blocks.
fn to_chunks(text: String) -> List(String) {
  case string.length(text) <= chunk_size {
    True ->
      case text {
        "" -> []
        _ -> [text]
      }
    False -> {
      let head = string.slice(text, 0, chunk_size)
      let tail = string.drop_start(text, chunk_size)
      [head, ..to_chunks(tail)]
    }
  }
}

// Fold over CSV rows using chunk-based reading.
// Incomplete rows at chunk boundaries are carried forward in a buffer.
pub fn fold_csv(text: String, init: b, f: fn(b, List(String)) -> b) -> b {
  do_fold_csv(to_chunks(text), "", init, f)
}

fn do_fold_csv(
  chunks: List(String),
  buffer: String,
  acc: b,
  f: fn(b, List(String)) -> b,
) -> b {
  case chunks {
    [] ->
      // Flush any remaining buffered content as the final row.
      case parse_row(buffer) {
        Error(_) -> acc
        Ok(fields) -> f(acc, fields)
      }
    [chunk, ..rest] -> {
      let combined = buffer <> chunk
      let lines = string.split(combined, "\n")
      let n = list.length(lines)
      // All lines except the last are complete rows.
      let complete = list.take(lines, n - 1)
      let leftover = case list.last(lines) {
        Ok(s) -> s
        Error(_) -> ""
      }
      let new_acc =
        list.fold(complete, acc, fn(a, line) {
          case parse_row(line) {
            Error(_) -> a
            Ok(fields) -> f(a, fields)
          }
        })
      do_fold_csv(rest, leftover, new_acc, f)
    }
  }
}

// mccole: /chunk_fn

pub fn main() {
  // mccole: main_example
  let csv = "name,age,score\nAlice,30,88\nBob,25,92\nCarol,35,79\n"

  let row_count = fold_with_header(csv, 0, fn(acc, _) { acc + 1 })
  io.println("data rows: " <> string.inspect(row_count))

  let total_score =
    fold_with_header(csv, 0, fn(acc, row) {
      case row {
        [_, _, score_str] ->
          case int.parse(score_str) {
            Ok(n) -> acc + n
            Error(_) -> acc
          }
        _ -> acc
      }
    })
  io.println("total score: " <> string.inspect(total_score))

  let chunk_count = fold_csv(csv, 0, fn(acc, _) { acc + 1 })
  io.println("chunk fold row count: " <> string.inspect(chunk_count))
  // mccole: /main_example
}
