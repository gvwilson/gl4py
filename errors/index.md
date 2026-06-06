# Results, Options, and Error Handling

<div class="callout" markdown="1">

-   Gleam has no exceptions: errors are ordinary values returned by functions.
-   The `Result` type carries either a success value (`Ok`) or a failure reason (`Error`).
    -   Functions that return `Result` force callers to acknowledge failure at compile time.
-   The `Option` type represents a value that may or may not be present.

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
    -   While `String` is convenient for examples,
        Gleam developers usually prefer an explicit custom error type
        so that the compiler can check that every error case is handled
    -   A custom error type is just another `type` definition:
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
-   `result.map(r, f)` applies `f` to the value inside `Ok` and rewraps it
-   `result.try(r, f)` is similar but `f` returns a `Result`,
    so the double-wrapping `Ok(Ok(v))` is avoided
    -   Most Gleam developers use `result.try` more often than `result.map`
-   `result.map_error` transforms the error value in `Error`
-   `result.unwrap` extracts the value from `Ok` or returns a default

[%inc src/map_demo.gleam mark=map_usage %]

[%inc out/map_demo.out %]

-   `result.map(r, f)` applies `f` to the value inside `Ok(v)` and returns `Ok(f(v))`
    -   If `r` is `Error(e)`, `result.map` returns `Error(e)` unchanged
-   This avoids a `case` expression when you only care about the success path

## The Option Type

-   [%g option_type "`Option(a)`" %] is a type with two variants
    -   `Some(value)` wraps a present value
    -   `None` represents absence
-   `Option` is used mostly for optional fields in records
    and optional function parameters
    -   For return types that might fail, `Result` is usually preferred
    -   `Result` can carry an error message; `Option` cannot

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
-   This is equivalent to Python's `next((x for x in items if x > 0), None)`
    but the return type makes the "might be absent" case explicit

## Guidelines for Handling Errors

-   Return `Result` whenever a function might fail for an externally visible reason
     (bad input, missing file, network error)
-   Return `Option` when absence is the only failure mode
-   Use `let assert Ok(x) = ...` only when failure truly cannot happen
    (like initialising a known-good constant at startup)
    -   It [%g panic "panics" %] on `Error`
    -   Unlike Python's `assert`, which is a statement that checks a condition,
        Gleam's `let assert` is a binding form:
        it matches a pattern and brings variables into scope

[%inc src/assert_demo.gleam mark=assert_demo %]
[%inc out/assert_demo.out %]

-   Use `result.try` and `result.map` for short transformations
-   Prefer custom error types over `String` for the error type
    in non-trivial programs

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

### First matching element (10 minutes)

Write `find(items: List(a), pred: fn(a) -> Bool) -> Option(a)`
that returns `Some(x)` for the first element where `pred(x)` is `True`,
or `None` if no element matches.
Write it using recursion with a `case` expression.

</div>
