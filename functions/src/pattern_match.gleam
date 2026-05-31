import gleam/io
import gleam/string

pub fn main() {
  io.println("(3, 4, 5) => " <> string.inspect(classify_triangle(3, 4, 5)))
  io.println("(5, 5, 5) => " <> string.inspect(classify_triangle(5, 5, 5)))
  io.println("(5, 5, 3) => " <> string.inspect(classify_triangle(5, 5, 3)))
  io.println("(2, 3, 4) => " <> string.inspect(classify_triangle(2, 3, 4)))
}

// mccole: triangle
type Triangle {
  Equilateral
  Isosceles
  Scalene
}

fn classify_triangle(a: Int, b: Int, c: Int) -> Triangle {
  case a, b, c {
    x, y, z if x == y && y == z -> Equilateral
    x, y, _ if x == y -> Isosceles
    _, y, z if y == z -> Isosceles
    x, _, z if x == z -> Isosceles
    _, _, _ -> Scalene
  }
}
// mccole: /triangle
