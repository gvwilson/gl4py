import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

// mccole: html_view_fn
fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.p([], [html.text(int.to_string(model.count))]),
    html.button([event.on_click(Increment)], [html.text("+")]),
    html.button([event.on_click(Decrement)], [html.text("-")]),
    html.button([event.on_click(Reset)],     [html.text("reset")]),
  ])
}
// mccole: /html_view_fn

// mccole: main_fn
pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}
// mccole: /main_fn

// mccole: form_types
type Model {
  Model(count: Int, input: String, items: List(String))
}

type Msg {
  Increment
  Decrement
  Reset
  InputChanged(String)
  AddItem
  RemoveItem(Int)
}
// mccole: /form_types
