import lustre/effect

// mccole: fetch_todos_fn
fn fetch_todos() -> effect.Effect(Msg) {
  effect.from(fn(dispatch) {
    // make HTTP request, then:
    dispatch(TodosLoaded(todos))
  })
}
// mccole: /fetch_todos_fn
