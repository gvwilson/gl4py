import gleam/int
import gleam/io
import gleam/string

pub fn main() {
  let nums = [1, 2, 3, 4, 5]
  io.println("length nums = " <> int.to_string(length(nums)))
  io.println("length [] = " <> int.to_string(length([])))

  io.println("factorial(5) = " <> int.to_string(factorial(5)))
  io.println("factorial(0) = " <> int.to_string(factorial(0)))

  io.println("take 3 = " <> string.inspect(take(nums, 3)))
  io.println("take 10 = " <> string.inspect(take(nums, 10)))
}

// mccole: length_fn
fn length(lst: List(a)) -> Int {
  case lst {
    [] -> 0
    [_, ..rest] -> 1 + length(rest)
  }
}

// mccole: /length_fn

// mccole: factorial_fn
fn factorial(n: Int) -> Int {
  factorial_tail(n, 1)
}

fn factorial_tail(n: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> factorial_tail(n - 1, acc * n)
  }
}

// mccole: /factorial_fn

// mccole: take_fn
fn take(lst: List(a), n: Int) -> List(a) {
  case lst, n {
    _, 0 -> []
    [], _ -> []
    [x, ..rest], _ -> [x, ..take(rest, n - 1)]
  }
}
// mccole: /take_fn
