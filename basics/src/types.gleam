import gleam/float
import gleam/io
import gleam/string

// mccole: type_defs
pub type Color {
  Red
  Green
  Blue
}

type Shape {
  Circle(Float)
  Rectangle(Float, Float)
}

// mccole: /type_defs

pub fn main() {
  let c = Red
  io.println("red is " <> string.inspect(c))

  let s1 = Circle(3.0)
  let s2 = Rectangle(4.0, 5.0)
  io.println("circle is " <> string.inspect(s1))
  io.println("rectangle is " <> string.inspect(s2))

  io.println("circle area is " <> float.to_string(area(s1)))
  io.println("rectangle area is " <> float.to_string(area(s2)))
}

// mccole: area_fn
fn area(shape: Shape) -> Float {
  case shape {
    Circle(r) -> 3.14159 *. r *. r
    Rectangle(w, h) -> w *. h
  }
}
// mccole: /area_fn
