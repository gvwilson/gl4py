# The use Expression

<div class="callout" markdown="1">

-   When several operations each return `Result`,
    nesting `case` expressions quickly becomes unreadable.
-   `use x <- f(...)` rewrites the rest of the block as a callback passed to `f`.
-   Any function that accepts a callback as its last argument works with `use`.
-   Combined with `result.try`, `use` eliminates deeply nested error-handling code.

</div>

## The Nesting Problem

-   When you call several functions that each return `Result`,
    you need to unwrap each one before using it
-   A single `case` is fine; three in a row is hard to read

[%inc src/nesting_demo.gleam mark=nested_ok %]
[%inc out/nesting_demo.out %]

-   `parse_int` converts a string to an integer, returning `Error` if the string is invalid
-   `safe_divide` divides two integers, returning `Error` if the denominator is zero
-   `validate_positive` checks that a number is positive, returning `Error` if it is not
-   Every step adds another level of indentation
    -   The actual computation (`validate_positive(quotient)`) is buried at the innermost level
-   When any step fails, every outer `Error(reason) -> Error(reason)` arm just re-wraps
    and propagates the same error without adding any information

[%inc src/nesting_demo.gleam mark=nested_err %]

-   Replacing `"6"` with `"0"` causes `safe_divide` to return an error
    -   The two outer arms still just pass the error along unchanged

## Flattening with use

-   `use` rewrites nested [%g callback "callback" %] as a flat sequence of steps
    -   This is called [%g syntactic_sugar "syntactic sugar" %] because it sweetens the language
    -   Translating the easy-to-read form into the basic form is called [%g desugaring "desugaring" %]
    -   This is what passes for wit among language designers
-   `result.try(result, callback)` calls `callback` with the value inside `Ok(x)`,
    or returns `Error` unchanged without calling the callback at all

[%inc src/use_result_demo.gleam mark=use_ok %]
[%inc out/use_result_demo.out %]

-   Each `use` line extracts the value from `Ok` and binds it to a name
-   If any step returns `Error`, the whole block [%g short_circuit "short-circuits" %]
    and produces that error immediately
    -   The remaining steps are never evaluated
    -   Because when `result.try` receives an `Error`,
        it returns it directly without calling the callback
-   The final expression is the result of the whole block
-   Compare the two versions: the `use` form reads like a plain sequence of steps

[%inc src/use_result_demo.gleam mark=use_err %]

-   `parse_int("0")` succeeds (zero is a valid integer),
    so `divisor` is bound to `0`
-   `safe_divide(30, 0)` returns `Error("division by zero")`
-   The block short-circuits there;
    `validate_positive` is never called

## How use Works

-   `use` is not special-cased for `Result`: it is a general rewrite rule
-   `use x <- f(a, b)` followed by a block of code is equivalent to:

```gleam
f(a, b, fn(x) {
  body
})
```

-   The `x` in `fn(x)` is exactly the same binding as the `x` introduced by `use x <-`
    -   The rewrite is one-for-one, so the name carries over directly
-   In other words: call `f` with its normal arguments plus one extra argument,
    a function that takes `x` and contains the rest of the block
-   The function that receives the callback decides what to do with it
    -   `result.try` calls the callback only when its first argument is `Ok(x)`,
        and propagates `Error` unchanged otherwise
-   Any function whose last parameter is a callback works with `use`
-   If the callback takes no arguments, omit the binding: `use <- f(a, b)`

## use Beyond Results

-   Because `use` is just a rewrite, it works with any function that accepts a callback

[%inc src/use_general_demo.gleam mark=callback_long %]
[%inc src/use_general_demo.gleam mark=callback_use %]

-   `with_greeting` takes a name and a callback, and passes the constructed greeting to the callback
-   Both forms produce the same output
    -   `use` just removes the anonymous function syntax
-   The `use` form expands to exactly the same call as the explicit version:

```gleam
with_greeting("with use", fn(greeting) {
  io.println(greeting)
})
```

[%inc src/use_general_demo.gleam mark=list_each %]
[%inc out/use_general_demo.out %]

-   `list.each` calls the callback once for each element of the list
-   `use item <- list.each([1, 2, 3])` is equivalent to writing
    `list.each([1, 2, 3], fn(item) { ... })`
-   The rest of the block becomes the body of the anonymous function
    -   No curly braces because it's a single expression

## Guidelines for use

-   Use `use x <- result.try(...)` when chaining three or more fallible operations
    -   For one or two operations, a `case` expression is often clearer
-   Prefer `result.try` for chaining; use `result.map` only for single-step transformations
-   `use` does not catch errors; it propagates them exactly as nested `case` would
-   Any function that takes a callback as its last argument works with `use`,
    not just functions from the `result` module
-   Do not nest `use` blocks inside `use` blocks; if you feel tempted to do so,
    extract a helper function instead

## Further Reading

-   The [Gleam language tour][gleam-tour-use] covers `use` with additional examples,
    including a discussion of how it relates to monadic bind in other languages.

## Check Understanding

<details markdown="1">
<summary markdown="1">What does `use x <- result.try(expr)` desugar to?</summary>

It desugars to:

```gleam
result.try(expr, fn(x) {
  rest of block
})
```

`result.try` calls the callback with the value inside `Ok(x)`,
or returns the `Error` unchanged without calling the callback at all.
The `use` line just removes the need to write the anonymous function explicitly.

</details>

<details markdown="1">
<summary markdown="1">Can you use `use` with a function that returns something other than `Result`?</summary>

Yes.
`use` works with any function whose last parameter is a callback.
The function controls what it does with that callback:
`result.try` calls it only on success,
`list.each` calls it once per element,
and a custom function can call it however it likes.
The `Result` type has no special relationship to `use`.

</details>

<details markdown="1">
<summary markdown="1">If `result.try` were replaced by a function that always calls its callback, could the block still short-circuit?</summary>

No.
Short-circuiting is not a property of `use` itself — it is a property of `result.try`.
`use` only rewrites syntax; whether the callback is called, skipped, or called multiple times depends entirely on what the receiving function does.
A function that always calls its callback will always execute the rest of the block, regardless of how many `use` lines appear.

</details>

## Exercises

<div class="exercise" markdown="1">

### Identify the callback (5 minutes)

Rewrite this `use` expression as an explicit callback without `use`:

```gleam
let result = {
  use name <- result.try(find_user(id))
  use score <- result.try(fetch_score(name))
  Ok(score * 2)
}
```

What type must `find_user` and `fetch_score` return for this to compile?

</div>

<div class="exercise" markdown="1">

### Three-step chain (15 minutes)

Write three functions:
`read_config(path: String) -> Result(String, String)` (returns `Error` if the path is empty),
`parse_port(raw: String) -> Result(Int, String)` (wraps `int.parse` with a descriptive error),
and `validate_port(port: Int) -> Result(Int, String)` (returns `Error` if the port is outside 1–65535).
Chain all three with `use` so that `read_config("")` short-circuits before the other two are called.

</div>

<div class="exercise" markdown="1">

### Custom use target (15 minutes)

Write `with_default(maybe: Option(a), default: a, callback: fn(a) -> b) -> b`
that calls `callback` with the value inside `Some`, or with `default` if the option is `None`.
Then use it with `use` to unwrap an `Option(Int)` and double the result,
falling back to `0` when the option is `None`.

</div>
