import gleam/int
import gleeunit
import gleeunit/should
import stream_demo.{fold_csv, fold_rows, fold_with_header, parse_row}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn parse_row_basic_test() {
  parse_row("a,b,c")
  |> should.equal(Ok(["a", "b", "c"]))
}

pub fn parse_row_single_field_test() {
  parse_row("hello")
  |> should.equal(Ok(["hello"]))
}

pub fn parse_row_empty_test() {
  parse_row("")
  |> should.be_error()
}

pub fn parse_row_whitespace_only_test() {
  parse_row("   ")
  |> should.be_error()
}

pub fn fold_rows_counts_test() {
  let csv = "Alice,30\nBob,25\nCarol,35"
  fold_rows(csv, 0, fn(acc, _) { acc + 1 })
  |> should.equal(3)
}

pub fn fold_rows_skips_blank_test() {
  let csv = "Alice,30\n\nBob,25"
  fold_rows(csv, 0, fn(acc, _) { acc + 1 })
  |> should.equal(2)
}

pub fn fold_with_header_skips_first_test() {
  let csv = "name,age\nAlice,30\nBob,25"
  fold_with_header(csv, 0, fn(acc, _) { acc + 1 })
  |> should.equal(2)
}

// mccole: /tests

pub fn fold_with_header_sum_test() {
  let csv = "name,score\nAlice,10\nBob,20\nCarol,30"
  let total =
    fold_with_header(csv, 0, fn(acc, row) {
      case row {
        [_, n_str] ->
          case int.parse(n_str) {
            Ok(n) -> acc + n
            Error(_) -> acc
          }
        _ -> acc
      }
    })
  total |> should.equal(60)
}

pub fn fold_csv_same_as_fold_rows_test() {
  let csv = "a,1\nb,2\nc,3"
  let by_line = fold_rows(csv, 0, fn(acc, _) { acc + 1 })
  let by_chunk = fold_csv(csv, 0, fn(acc, _) { acc + 1 })
  by_line |> should.equal(by_chunk)
}
