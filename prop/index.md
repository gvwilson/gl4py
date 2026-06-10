# Property-Based Testing

<div class="syllabus" markdown="1">

-   Unit tests check specific examples;
    property-based tests check universal statements
    that must hold for any generated input.
-   A generator is a function from a seed to a value and a new seed,
    enabling reproducible pseudo-random generation.
-   Composing generators with `list_of` and other combinators builds generators
    for complex types from simple ones.
-   `check` runs a property against many generated values
    and returns the first counterexample it finds.
-   Shrinking reduces a failing input to the smallest version
    that still triggers the failure; this lesson explains the concept
    without implementing it.

</div>

## Why Properties?

-   A test like `let result = word_count(["the", "the"]); let assert True = result == dict.from_list([#("the", 2)])`
    checks one input
-   A property like "for all word lists, the total count equals the list length"
    checks an infinite family of inputs
-   [%g property_based_testing "Property-based testing" %] was popularized by Haskell's QuickCheck;
    today every major language has a property testing library
-   Properties catch bugs that no one thought to add as an example:
    the sorting code that fails for lists of length 1,
    the encoder that drops the last byte when the input length is a multiple of 8
-   This lesson builds a minimal property tester from scratch
    to expose the mechanics; real projects would use an established library

## Seeds and the Generator Type

[%inc src/prop_demo.gleam mark=types %]

[%inc src/prop_demo.gleam mark=seed_fn %]

-   A `Seed` wraps a single integer;
    any integer is a valid starting seed
-   `next` advances the seed using a [%g lcg "linear congruential generator" %] (LCG):
    multiply and add, then take the absolute value to stay positive
-   Because Gleam runs on the BEAM and Erlang uses arbitrary-precision integers,
    there is no overflow; the numbers just grow until `abs` brings them back
-   `Gen(a)` is a type alias for a function that takes a seed
    and returns a generated value paired with the next seed
-   The seed-threading style means generators are pure and reproducible:
    the same seed always produces the same sequence

## Basic Generators

[%inc src/prop_demo.gleam mark=generators %]

-   `int_between(lo, hi)` calls `next` to get a raw integer,
    then maps it into the range `[lo, hi]` using `%`
-   `list_of(gen, count)` calls `gen` exactly `count` times,
    threading the seed forward on each call,
    and collects the values into a list
-   `do_list_of` is the tail-recursive worker:
    it prepends values to `acc` and reverses at the end,
    keeping each step O(1)
-   Composing generators is the normal way to build generators for complex types:
    `list_of(int_between(-100, 100), 10)` is a [%g generator "generator" %]
    for ten-element lists of integers

## The Check Function

[%inc src/prop_demo.gleam mark=check_fn %]

-   `check` runs the property against `trials` generated values
-   `do_check` is the recursive worker:
    generate a value, test the property, recurse if it passes, return `Error(val)` if it fails
-   Returning `Error(val)` rather than just `Error(Nil)` lets the caller
    see the specific counterexample that broke the property
-   A real property testing library would also [%g shrinking "shrink" %] the counterexample:
    repeatedly simplify `val` until no simpler version still fails,
    giving a minimal, readable test case

## Running the Example

[%inc src/prop_demo.gleam mark=main_example %]

-   `reverse_twice` passes because `list.reverse(list.reverse(xs)) == xs` for every list
-   `sort_idempotent` passes because sorting an already-sorted list is a no-op
-   `always_positive` fails immediately:
    the generator produces both positive and negative integers,
    so the first negative value that appears is the counterexample

## Testing

[%inc test/prop_test.gleam mark=tests %]

-   `next_changes_seed_test` confirms that the generator advances:
    applying `next` twice gives two different seeds
-   `int_between_in_range_test` confirms the range constraint holds for one seed
-   `int_between_deterministic_test` confirms that the same seed always produces
    the same value, which is the reproducibility guarantee
-   `check_finds_counterexample_test` verifies that `check` returns `Error`
    for a property that is demonstrably false

## Check Understanding

<details markdown="1">
<summary markdown="1">Why does `check` return `Error(val)` where `val` is the failing input,
rather than just `Error("property failed")`?</summary>

Knowing which value triggered the failure is the whole point of property testing.
A bare error message tells you the test failed;
the failing value tells you what to investigate.
In a real library, you would then pass that value to a shrinker
to find the minimal failing case.
Returning `Error(val)` also keeps the return type polymorphic in `a`,
meaning `check` works for any generator without needing a separate error type.

</details>

<details markdown="1">
<summary markdown="1">The `int_between(0, 10)` generator uses `raw % range` to stay in bounds.
What goes wrong if `lo > hi`?</summary>

`range = hi - lo + 1` becomes zero or negative.
Division by zero in Erlang raises a `badarith` exception,
crashing the process.
A production generator would validate that `lo <= hi` and return `Error`
or `panic` with a useful message.
For this lesson, the contract is that `lo <= hi`;
violating it is a programming error, not a runtime event to handle.

</details>

## Exercises

<div class="exercise" markdown="1">

### String generator (15 minutes)

Write `string_of(chars: List(String), len: Int) -> Gen(String)`
that generates a string of exactly `len` characters chosen randomly from `chars`.
Use `list_of` and `int_between(0, list.length(chars) - 1)` as the character picker.
Write a property test confirming that every generated string has the right length.

</div>

<div class="exercise" markdown="1">

### Roundtrip property (15 minutes)

Using `int_between`, write a property test for the `encode`/`decode` roundtrip
from the [binary](@/binary/) lesson:
for any integer in the range that the packer supports,
`decode(encode(n)) == n`.
Run 500 trials.

</div>

<div class="exercise" markdown="1">

### Shrinking (20 minutes)

Add a `shrink_int(n: Int) -> List(Int)` function that returns a list of smaller
candidate values to try: `[0, n / 2, n - 1]`
(filtered to remove duplicates and values equal to `n`).
Modify `do_check` to call `shrink_int` on the first failing value
and keep shrinking as long as smaller values also fail,
returning the smallest failing value found.
Test that a property like `n < 3` produces a counterexample of exactly `3`.

</div>

<div class="exercise" markdown="1">

### Pair generator (10 minutes)

Write `pair_of(gen_a: Gen(a), gen_b: Gen(b)) -> Gen(#(a, b))`
that generates a pair by running both generators in sequence,
threading the seed through.
Use it to write a property test confirming that `dict.merge(a, b)`
always contains at least as many keys as `dict.size(a)`.

</div>
