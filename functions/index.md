# Functions, Pattern Matching, Lists, and Pipelines

<div class="callout" markdown="1">

-   Gleam has no `for` or `while` loops: use recursion instead.
-   Tail recursion with an accumulator prevents stack overflow for large inputs.
-   The `|>` pipeline operator threads a value through a sequence of transformations.

</div>

## Defining Functions

-   A Gleam function is introduced with `fn`,
    followed by a name, parameter list, optional return type, and a body

```gleam
fn add(a: Int, b: Int) -> Int {
  a + b
}
```

-   Parameter types are written `name: Type`
-   The return type after `->` is optional but recommended
-   The body is a block of expressions, the last of which is the function's result
-   `pub fn` exports the function; plain `fn` keeps it private to the module
-   Functions can call themselves recursively and can be passed as values

## Pattern Matching

-   Gleam's `case` expression is the primary tool for working with structured data
-   It can match on custom types, lists, tuples, integers, and strings
-   And can match several values simultaneously

[%inc src/pattern_match.gleam mark=triangle %]

-   `type Triangle { Equilateral Isosceles Scalene }` defines the three possible results
-   `case a, b, c { ... }` matches on three values at once
    -   This is more concise than three nested `if` statements
-   `x, y, z if x == y && y == z -> Equilateral` is a [%g guarded_arm "guarded arm" %]
    -   The pattern `x, y, z` binds the three values to names
    -   The `if` condition must also be true for the arm to match
    -   Without guards this would require a `case` inside a `case`
-   The arms are tried in order, with the first match winning
-   The compiler verifies that the arms cover all possibilities

[%inc src/palindrome.gleam mark=palindrome %]

-   `string.to_graphemes` splits a string into a list of characters
    -   [%g grapheme "Graphemes" %], not bytes, so emoji and accented letters work
-   `list.reverse` returns a new list without modifying the original
-   `==` compares lists element by element

## Recursion Instead of Loops

-   Gleam has no `for` or `while` loops
-   Repetition is expressed through recursion

[%inc src/recursion.gleam mark=length_fn %]

-   `case lst { [] -> 0 [_, ..rest] -> 1 + length(rest) }` is the
    standard recursive structure on lists
    -   `[]` matches the empty list, so the [%g base_case "base case" %] returns 0
    -   `[_, ..rest]` matches a non-empty list:
         `_` discards the head, `rest` binds the tail
-   The [%g type_parameter "type parameter" %] `a` means `length` works on any list
    regardless of the elements' type
-   This version grows the call stack with each recursive call
    -   That's a problem for large lists

## Tail Recursion

-   [%g tail_recursion "Tail recursion" %] eliminates stack growth
    by accumulating the result in a parameter instead of on the call stack

[%inc src/recursion.gleam mark=factorial_fn %]

-   `factorial` is the public entry point:
    it calls the worker with an initial accumulator of 1
-   `factorial_tail` is the tail-recursive worker
    -   When `n` is 0, return the accumulated result
    -   Otherwise, multiply `acc` by `n` and recurse with `n - 1`
    -   The recursive call is the last operation; nothing waits for it to return
-   The Gleam compiler (and the BEAM VM) optimise tail calls so they do not grow the stack

[%inc src/recursion.gleam mark=take_fn %]
[%inc out/recursion.out %]

-   Matching on two values simultaneously: `case lst, n { ... }`
-   Three base cases: `n = 0` (done), empty list (done), otherwise take one element and recurse
-   The result is built by [%g prepend "prepending" %] `[x, ..take(rest, n - 1)]`

## Lists and Higher-Order Functions

-   Gleam's `List` type is a singly-linked list
-   The standard library provides `list.map`, `list.filter`, and `list.fold`
    that cover most iteration needs
-   `list.map(lst, f)` applies `f` to every element and returns a new list
    -   Like Python's `[f(x) for x in lst]`
-   `list.filter(lst, pred)` keeps elements where `pred` returns `True`
    -   Like Python's `[x for x in lst if pred(x)]`
-   `list.fold(lst, init, f)` combines elements left to right using `f`
    -   `list.fold([1,2,3], 0, fn(acc, x) { acc + x })` gives `6`
    -   Like Python's `functools.reduce(f, lst, init)`
-   Anonymous functions use `fn(args) { body }`:

```gleam
list.map([1, 2, 3], fn(x) { x * 2 })
// => [2, 4, 6]
```

## The Pipeline Operator

-   The `|>` operator passes the result of one expression as the first argument of the next
-   Lets you write a sequence of transformations left to right
    -   Easier to read than nested calls

[%inc src/pipeline.gleam mark=pipeline %]
[%inc out/pipeline.out %]

-   `[1, 2, 3, 4, 5] |> list.map(fn(x) { x * 2 })` doubles every element
    -   `|>` passes the list as the first argument to `list.map`
    -   `fn(x) { x * 2 }` is an anonymous function
-   `|> list.filter(fn(x) { x > 10 })` keeps only values greater than 10
-   `|> list.fold(0, fn(acc, x) { acc + x })` sums the remaining values
-   The whole pipeline reads left to right: double, filter, sum
    -   Much cleaner than Python equivalent

```python
reduce(lambda a, x: a+x, filter(lambda x: x>10, map(lambda x: x*2, lst)), 0)
```

## Check Understanding

<details markdown="1">
<summary markdown="1">What does "exhaustive" mean for a case expression?</summary>

An exhaustive match covers every possible value of the type being matched.
If you write a `case` on a `Triangle` but only handle `Equilateral` and
`Isosceles`, the compiler reports an error because `Scalene` is not
covered.
This prevents a common class of bug where a new variant is added to a type
and existing match expressions silently fall through to a catch-all.

</details>

<details markdown="1">
<summary markdown="1">When should you use `list.fold` instead of `list.map` or `list.filter`?</summary>

Use `list.fold` when you need to combine all elements of a list into a single value,
like a sum or a product.
`list.map` transforms each element independently;
`list.filter` selects a subset of elements.
Many operations that would use a `for` loop in Python can be expressed
with one of these three functions in Gleam.

</details>

## Exercises

<div class="exercise" markdown="1">

### Recursive sum (5 minutes)

Write `sum(lst: List(Int)) -> Int` using tail recursion with an accumulator.
Verify that `sum([1, 2, 3, 4, 5])` returns `15` and `sum([])` returns `0`.

</div>

<div class="exercise" markdown="1">

### Palindrome checker (10 minutes)

Write `is_palindrome(s: String) -> Bool` using `string.to_graphemes` and `list.reverse`.
Test it with `"racecar"`, `"gleam"`, and at least one string with a non-ASCII character.

</div>

<div class="exercise" markdown="1">

### Pipeline challenge (10 minutes)

Use a single pipeline to take the list `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]`,
keep only odd numbers, square each one, and sum the results.
The answer should be `165`.

</div>

<div class="exercise" markdown="1">

### Triangle classifier (10 minutes)

Extend the `classify_triangle` function to also return a label for right triangles.
A triangle with sides `a`, `b`, `c` (where `c` is the longest side)
is a right triangle if `a*a + b*b == c*c`.
Determine the correct arm ordering so that an equilateral triangle is never labelled as right.

</div>
