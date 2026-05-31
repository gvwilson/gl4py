import gleam/int
import gleam/io
import gleam/list
import gleam/string

// mccole: types
// A seed for the pseudo-random number generator.
// Any integer is a valid seed.
pub type Seed {
    Seed(Int)
}

// A generator produces a value and a new seed.
pub type Gen(a) =
    fn(Seed) -> #(a, Seed)
// mccole: /types

// mccole: seed_fn
// Advance the seed using a linear congruential generator.
// Multiplier and increment are from Numerical Recipes.
pub fn next(seed: Seed) -> #(Int, Seed) {
    let Seed(n) = seed
    let raw = n * 1_664_525 + 1_013_904_223
    let next_n = case raw < 0 {
        True -> -raw
        False -> raw
    }
    #(next_n, Seed(next_n))
}
// mccole: /seed_fn

// mccole: generators
pub fn int_between(lo: Int, hi: Int) -> Gen(Int) {
    fn(seed) {
        let #(raw, next_seed) = next(seed)
        let range = hi - lo + 1
        let val = lo + raw % range
        #(val, next_seed)
    }
}

pub fn list_of(gen: Gen(a), count: Int) -> Gen(List(a)) {
    fn(seed) { do_list_of(gen, count, seed, []) }
}

fn do_list_of(
    gen: Gen(a),
    remaining: Int,
    seed: Seed,
    acc: List(a),
) -> #(List(a), Seed) {
    case remaining {
        0 -> #(list.reverse(acc), seed)
        _ -> {
            let #(val, next_seed) = gen(seed)
            do_list_of(gen, remaining - 1, next_seed, [val, ..acc])
        }
    }
}
// mccole: /generators

// mccole: check_fn
// Run a property against `trials` generated values starting from `seed`.
// Returns Ok(Nil) if all trials pass, or Error(failing_value) on the first failure.
pub fn check(
    gen: Gen(a),
    prop: fn(a) -> Bool,
    trials: Int,
    seed: Seed,
) -> Result(Nil, a) {
    do_check(gen, prop, trials, seed)
}

fn do_check(
    gen: Gen(a),
    prop: fn(a) -> Bool,
    remaining: Int,
    seed: Seed,
) -> Result(Nil, a) {
    case remaining {
        0 -> Ok(Nil)
        _ -> {
            let #(val, next_seed) = gen(seed)
            case prop(val) {
                True -> do_check(gen, prop, remaining - 1, next_seed)
                False -> Error(val)
            }
        }
    }
}
// mccole: /check_fn

pub fn main() {
    // mccole: main_example
    let seed = Seed(42)
    let int_gen = int_between(-50, 50)
    let list_gen = list_of(int_between(-100, 100), 8)

    let reverse_twice =
        check(list_gen, fn(xs) { list.reverse(list.reverse(xs)) == xs }, 200, seed)
    io.println("reverse twice: " <> string.inspect(reverse_twice))

    let sort_idempotent = check(
        list_gen,
        fn(xs) {
            let sorted = list.sort(xs, int.compare)
            list.sort(sorted, int.compare) == sorted
        },
        200,
        seed,
    )
    io.println("sort idempotent: " <> string.inspect(sort_idempotent))

    // This property is false: not every integer is non-negative.
    let always_positive = check(int_gen, fn(n) { n >= 0 }, 200, seed)
    io.println(
        "all non-negative (should fail): " <> string.inspect(always_positive),
    )
    // mccole: /main_example
}
