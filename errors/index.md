# Results, Options, and Error Handling

<div class="callout" markdown="1">

-   Gleam has no exceptions: errors are ordinary values returned by functions.
-   The `Result` type carries either a success value (`Ok`) or a failure reason (`Error`).
    -   Functions that return `Result` force callers to acknowledge failure at compile time.
-   The `Option` type represents a value that may or may not be present.
-   The `use` expression eliminates deeply nested `case` blocks
     when chaining multiple fallible operations.

</div>

## Errors as Values

-   Python raises an exception when something goes wrong
    and expects callers to catch it with `try`/`except`
-   But nothing in the type signature tells you whether a function might raise
    or what kind of exception to expect
-   In Gleam, a function that might fail returns a [%g result_type "Result" %],
     and the type signature makes that explicit
-   `Result(a, e)` is a type with two variants:
    -   `Ok(value)` carries a successful result
    -   `Error(reason)` carries a failure description
-   The type of `reason` is up to you
    -   It can be a `String`, a custom error type, or anything else
-   A caller cannot use the value inside `Ok` without handling the `Error` case
    -   The compiler enforces this

## Parsing and Dividing Safely

[%inc src/result_demo.gleam mark=parse_fn %]

-   `int.parse(s)` from the standard library returns `Result(Int, Nil)`
    -   It returns `Ok(n)` if the string is a valid integer
    -   It returns `Error(Nil)` if not; the error carries no information
-   The function wraps the result to provide a `String` error message instead
-   Compare to Python's `int(s)`
    -   Raises `ValueError` on bad input
    -   But no way to know this from the function's type

[%inc src/result_demo.gleam mark=divide_fn %]
[%inc out/result_demo.out %]

-   `safe_divide` returns `Error("division by zero")`
    instead of crashing with a `ZeroDivisionError`
-   The `case b { 0 -> … _ -> … }` pattern is idiomatic for this kind of guard
-   Any caller that uses `safe_divide` must handle both `Ok` and `Error`

## Transforming Results

-   Often want to apply a function to the value inside `Ok` without unwrapping it manually
-   `result.map` does exactly that.

[%inc src/map_demo.gleam mark=map_usage %]

[%inc out/map_demo.out %]

-   `result.map(r, f)` applies `f` to the value inside `Ok(v)` and returns `Ok(f(v))`
    -   If `r` is `Error(e)`, `result.map` returns `Error(e)` unchanged
-   This avoids a `case` expression when you only care about the success path

## The Option Type

-   [%g option_type "`Option(a)`" %] is a type with two variants
    -   `Some(value)` wraps a present value
    -   `None` represents absence

[%inc src/option_demo.gleam mark=option_case %]

-   `Option(Int)` is exactly like Python's `Optional[int]`
-   `case opt { Some(n) -> ... None -> ... }` is the standard way to unwrap it
-   The compiler will not let you use `n` outside the `Some` arm

[%inc src/option_demo.gleam mark=first_pos %]
[%inc out/option_demo.out %]

-   `[x, .._rest] if x > 0` combines a list pattern with a guard
    -   If the head `x` is positive, return `Some(x)` immediately
    -   Otherwise, recurse on the tail
-   An empty list or an all-negative list reaches `[] -> None`
-   This is equivalent to Python's `next((x for x in lst if x > 0), None)`
    but the return type makes the "might be absent" case explicit

## Chaining with `use`

-   When you have several operations that each return `Result`,
    nesting `case` expressions becomes unpleasant quickly
-   `use` is [%g syntactic_sugar "syntactic sugar" %] that flattens this nesting

[%inc src/use_demo.gleam mark=use_success %]

-   `use x <- result.try(parse_int("10"))` is equivalent to:

```gleam
case parse_int("10") {
  Ok(x) -> ...rest of block...
  Error(e) -> Error(e)
}
```

-   Reading top to bottom: parse 10, parse 20, divide their sum by 3, double the result
-   Each `use` line binds a name from the `Ok` value
    or [%g short_circuit "short-circuits" %] with the `Error`
-   The final expression `Ok(z * 2)` is the result of the whole block

[%inc src/use_demo.gleam mark=use_fail %]
[%inc out/use_demo.out %]

-   `parse_int("bad")` returns `Error("not an integer: bad")`
-   The `use` expression short-circuits at that point
    -   `safe_divide` is never called
    -   The whole block evaluates to `Error("not an integer: bad")`
-   Analogous to Python's `try`/`except`,
    but the short-circuiting is explicit in the types
    rather than hidden in the runtime

## Guidelines for Handling Errors

-   Return `Result` whenever a function might fail for an externally visible reason
     (bad input, missing file, network error)
-   Return `Option` when absence is the only failure mode
-   Use `let assert Ok(x) = ...` only when failure truly cannot happen
    (like initialising a known-good constant at startup)
    -   It [%g panic "panics" %] on `Error`
-   Use `result.map` and `result.try` for short transformations
-   Use `use` for chains of three or more fallible operations

## Check Understanding

<details markdown="1">
<summary markdown="1">When should you use Option instead of Result?</summary>

-   Use `Option` when there is no useful error information to convey:
    a dictionary lookup either finds the key or it does not,
    and there is no meaningful "reason it failed".

-   Use `Result` when you want to distinguish failure modes:
    parsing an integer from a string can fail because the string is empty,
    because it contains non-digit characters, or because it overflows.
    A `Result` lets you report which failure occurred.

</details>

<details markdown="1">
<summary markdown="1">How does the `use` expression compare to Python's `try`/`except`?</summary>

In Python,
`try`/`except` catches exceptions that are raised anywhere in the block,
regardless of whether the function signature mentions them.
Gleam's `use` only short-circuits when a function explicitly returns an `Error` variant.
This means you always know from the type whether a function can fail,
and the `use` block's short-circuiting is visible in the code structure.
The practical difference is that Python's exceptions are invisible in type signatures,
while Gleam's `Result` values are not.

</details>

## Exercises

<div class="exercise" markdown="1">

### Safe division (5 minutes)

Write `safe_divide(a: Int, b: Int) -> Result(Int, String)`
that returns `Error("division by zero")` when `b` is 0
and `Ok(a / b)` otherwise.

</div>

<div class="exercise" markdown="1">

### Mapping over results (5 minutes)

Write a function that takes a `List(String)` and returns a `List(Int)`
containing only the elements that parse successfully as integers.
Use `int.parse`, `list.filter_map`, or a combination of `list.map` and `list.filter`.

</div>

<div class="exercise" markdown="1">

### Chaining with use (15 minutes)

Write three functions that each return `Result(Int, String)`:
`parse_age(s: String)`,
`validate_age(n: Int)` (returns `Error` if `n < 0` or `n > 150`),
and `to_birth_year(age: Int)` that subtracts from the current year.
Chain them with `use` so that (for example)
`"26"` produces `Ok(2000)` and `"-5"` produces an error at the validation step.

</div>

<div class="exercise" markdown="1">

### First matching element (10 minutes)

Write `find(lst: List(a), pred: fn(a) -> Bool) -> Option(a)`
that returns `Some(x)` for the first element where `pred(x)` is `True`,
or `None` if no element matches.
Write it using recursion with a `case` expression.

</div>
