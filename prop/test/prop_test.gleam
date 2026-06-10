import gleam/int
import gleam/list
import gleeunit
import gleeunit/should
import prop_demo.{Seed, check, int_between, list_of, next}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn next_changes_seed_test() {
  let #(_, s2) = next(Seed(1))
  let #(_, s3) = next(s2)
  s2 |> should.not_equal(s3)
}

pub fn int_between_in_range_test() {
  let gen = int_between(1, 10)
  let #(val, _) = gen(Seed(99))
  { val >= 1 && val <= 10 } |> should.be_true()
}

pub fn int_between_deterministic_test() {
  let gen = int_between(0, 100)
  let #(a, _) = gen(Seed(7))
  let #(b, _) = gen(Seed(7))
  a |> should.equal(b)
}

pub fn list_of_length_test() {
  let gen = list_of(int_between(0, 10), 5)
  let #(result, _) = gen(Seed(1))
  list.length(result) |> should.equal(5)
}

pub fn reverse_twice_is_identity_test() {
  let gen = list_of(int_between(-100, 100), 10)
  check(gen, fn(xs) { list.reverse(list.reverse(xs)) == xs }, 100, Seed(42))
  |> should.equal(Ok(Nil))
}

// mccole: /tests

pub fn sort_idempotent_test() {
  let gen = list_of(int_between(-100, 100), 10)
  check(
    gen,
    fn(xs) {
      let sorted = list.sort(xs, int.compare)
      list.sort(sorted, int.compare) == sorted
    },
    100,
    Seed(42),
  )
  |> should.equal(Ok(Nil))
}

pub fn check_finds_counterexample_test() {
  // Claiming every integer in [0..10] is > 5 is false.
  let gen = int_between(0, 10)
  check(gen, fn(n) { n > 5 }, 200, Seed(1))
  |> should.be_error()
}

pub fn check_passes_when_true_test() {
  let gen = int_between(1, 100)
  check(gen, fn(n) { n > 0 }, 200, Seed(42))
  |> should.equal(Ok(Nil))
}
