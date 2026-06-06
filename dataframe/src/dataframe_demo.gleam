import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

// mccole: column_type
pub type Column {
  IntCol(List(Int))
  StrCol(List(String))
}

// mccole: /column_type

// mccole: dataframe_type
pub type Dataframe {
  Dataframe(cols: dict.Dict(String, Column), nrows: Int)
}

// mccole: /dataframe_type

fn col_length(col: Column) -> Int {
  case col {
    IntCol(xs) -> list.length(xs)
    StrCol(xs) -> list.length(xs)
  }
}

// mccole: make_fn
pub fn make(pairs: List(#(String, Column))) -> Result(Dataframe, String) {
  case pairs {
    [] -> Ok(Dataframe(cols: dict.new(), nrows: 0))
    [#(_, first), ..] -> {
      let n = col_length(first)
      let bad =
        list.find(pairs, fn(p) {
          let #(_, col) = p
          col_length(col) != n
        })
      case bad {
        Ok(#(name, _)) -> Error("column '" <> name <> "' has wrong length")
        Error(_) -> Ok(Dataframe(cols: dict.from_list(pairs), nrows: n))
      }
    }
  }
}

// mccole: /make_fn

// mccole: accessor_fns
pub fn nrows(df: Dataframe) -> Int {
  df.nrows
}

pub fn ncols(df: Dataframe) -> Int {
  dict.size(df.cols)
}

pub fn int_col(df: Dataframe, name: String) -> Result(List(Int), String) {
  case dict.get(df.cols, name) {
    Error(_) -> Error("no column '" <> name <> "'")
    Ok(StrCol(_)) -> Error("column '" <> name <> "' is not integer")
    Ok(IntCol(xs)) -> Ok(xs)
  }
}

pub fn str_col(df: Dataframe, name: String) -> Result(List(String), String) {
  case dict.get(df.cols, name) {
    Error(_) -> Error("no column '" <> name <> "'")
    Ok(IntCol(_)) -> Error("column '" <> name <> "' is not string")
    Ok(StrCol(xs)) -> Ok(xs)
  }
}

// mccole: /accessor_fns

// mccole: select_fn
pub fn select(df: Dataframe, names: List(String)) -> Result(Dataframe, String) {
  list.fold(names, Ok([]), fn(acc_result, name) {
    case acc_result {
      Error(_) -> acc_result
      Ok(acc) ->
        case dict.get(df.cols, name) {
          Error(_) -> Error("no column '" <> name <> "'")
          Ok(col) -> Ok([#(name, col), ..acc])
        }
    }
  })
  |> result.map(fn(pairs) {
    Dataframe(cols: dict.from_list(list.reverse(pairs)), nrows: df.nrows)
  })
}

// mccole: /select_fn

// mccole: col_sum_fn
pub fn col_sum(df: Dataframe, name: String) -> Result(Int, String) {
  int_col(df, name)
  |> result.map(fn(xs) { list.fold(xs, 0, fn(acc, x) { acc + x }) })
}

// mccole: /col_sum_fn

// mccole: filter_fn
pub fn filter_rows(
  df: Dataframe,
  name: String,
  pred: fn(Int) -> Bool,
) -> Result(Dataframe, String) {
  use xs <- result.try(int_col(df, name))
  let mask = list.map(xs, pred)
  let new_cols =
    dict.to_list(df.cols)
    |> list.map(fn(pair) {
      let #(n, col) = pair
      #(n, keep_by_mask(col, mask))
    })
    |> dict.from_list
  let new_nrows = list.length(list.filter(mask, fn(b) { b }))
  Ok(Dataframe(cols: new_cols, nrows: new_nrows))
}

fn keep_by_mask(col: Column, mask: List(Bool)) -> Column {
  case col {
    IntCol(xs) -> IntCol(keep_where(xs, mask))
    StrCol(xs) -> StrCol(keep_where(xs, mask))
  }
}

fn keep_where(values: List(a), mask: List(Bool)) -> List(a) {
  list.zip(values, mask)
  |> list.fold([], fn(acc, pair) {
    case pair {
      #(v, True) -> [v, ..acc]
      _ -> acc
    }
  })
  |> list.reverse
}

// mccole: /filter_fn

pub fn main() {
  // mccole: main_example
  let data = [
    #("name", StrCol(["Alice", "Bob", "Carol"])),
    #("age", IntCol([30, 25, 35])),
    #("score", IntCol([88, 92, 79])),
  ]
  case make(data) {
    Error(msg) -> io.println("error: " <> msg)
    Ok(df) -> {
      io.println("nrows=" <> int.to_string(nrows(df)))
      io.println("ncols=" <> int.to_string(ncols(df)))
      io.println("total score=" <> string.inspect(col_sum(df, "score")))
      case filter_rows(df, "age", fn(age) { age >= 30 }) {
        Error(msg) -> io.println("filter error: " <> msg)
        Ok(seniors) -> {
          io.println("age >= 30: " <> int.to_string(nrows(seniors)) <> " rows")
          io.println("names: " <> string.inspect(str_col(seniors, "name")))
        }
      }
    }
  }

  io.println(
    "bad lengths: "
    <> string.inspect(
      make([
        #("x", IntCol([1, 2, 3])),
        #("y", IntCol([4, 5])),
      ]),
    ),
  )
  // mccole: /main_example
}
