// mccole: gleam_crash
fn process(n: Int) -> Int {
  let assert n >= 0  // panics on negative input
  n * 2
}
// mccole: /gleam_crash
