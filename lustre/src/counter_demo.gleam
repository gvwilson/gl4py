import gleam/int
import gleam/io

pub fn main() {
  io.println("starting counter simulation")
  io.println("---")

  // mccole: console_demo
  let model = init()
  let model = update(model, Increment)
  let model = update(model, Increment)
  let model = update(model, Decrement)
  io.println(view(model))
  // mccole: /console_demo
}

// mccole: model_msg_type
pub type Model {
  Model(count: Int)
}

pub type Msg {
  Increment
  Decrement
  Reset
}

// mccole: /model_msg_type

pub fn init() -> Model {
  Model(0)
}

// mccole: update_fn
pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Increment -> Model(model.count + 1)
    Decrement -> Model(model.count - 1)
    Reset -> Model(0)
  }
}

// mccole: /update_fn

// mccole: view_fn
pub fn view(model: Model) -> String {
  let sign = case model.count {
    c if c > 0 -> "+"
    c if c < 0 -> "-"
    _ -> ""
  }
  "Count: " <> sign <> int.to_string(model.count) <> " (click + or - to change)"
}
// mccole: /view_fn
