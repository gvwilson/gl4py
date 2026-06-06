import dataframe_demo.{
  IntCol, StrCol, col_sum, filter_rows, int_col, make, ncols, nrows, select,
  str_col,
}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn make_valid_test() {
  make([#("x", IntCol([1, 2, 3])), #("y", StrCol(["a", "b", "c"]))])
  |> should.be_ok()
}

pub fn make_length_mismatch_test() {
  make([#("x", IntCol([1, 2, 3])), #("y", IntCol([4, 5]))])
  |> should.be_error()
}

pub fn make_empty_test() {
  make([])
  |> should.be_ok()
}

pub fn nrows_test() {
  let df = make([#("x", IntCol([1, 2, 3]))]) |> should.be_ok()
  nrows(df) |> should.equal(3)
}

pub fn ncols_test() {
  let df = make([#("a", IntCol([1])), #("b", StrCol(["x"]))]) |> should.be_ok()
  ncols(df) |> should.equal(2)
}

pub fn int_col_exists_test() {
  let df = make([#("n", IntCol([10, 20]))]) |> should.be_ok()
  int_col(df, "n") |> should.equal(Ok([10, 20]))
}

pub fn int_col_missing_test() {
  let df = make([#("n", IntCol([1]))]) |> should.be_ok()
  int_col(df, "z") |> should.be_error()
  Nil
}

pub fn col_sum_test() {
  let df = make([#("v", IntCol([1, 2, 3, 4]))]) |> should.be_ok()
  col_sum(df, "v") |> should.equal(Ok(10))
}

pub fn select_keeps_named_cols_test() {
  let df =
    make([
      #("a", IntCol([1, 2])),
      #("b", StrCol(["x", "y"])),
      #("c", IntCol([3, 4])),
    ])
    |> should.be_ok()
  let sub = select(df, ["a", "c"]) |> should.be_ok()
  ncols(sub) |> should.equal(2)
}

pub fn select_missing_col_test() {
  let df = make([#("a", IntCol([1]))]) |> should.be_ok()
  select(df, ["a", "z"]) |> should.be_error()
  Nil
}

pub fn filter_rows_test() {
  let df =
    make([
      #("name", StrCol(["Alice", "Bob", "Carol"])),
      #("age", IntCol([30, 25, 35])),
    ])
    |> should.be_ok()
  let filtered = filter_rows(df, "age", fn(age) { age >= 30 }) |> should.be_ok()
  nrows(filtered) |> should.equal(2)
  str_col(filtered, "name") |> should.equal(Ok(["Alice", "Carol"]))
}
// mccole: /tests
