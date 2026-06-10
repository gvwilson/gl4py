# Modules, Imports, and Testing

<div class="syllabus" markdown="1">

-   Gleam modules map one-to-one to source files:
    the file path determines the module name
-   Opaque types expose a type name without revealing its internal representation
-   The `gleeunit` test framework runs tests from files in the `test/` directory

</div>

## Modules and Files

-   Every Gleam source file is a module
-   The module name comes from the file path relative to `src/`
    -   `src/myapp/utils.gleam` becomes the module `myapp/utils`
-   `import myapp/utils` makes the module's `func` available as `utils.func`
-   `import myapp/utils.{my_fn}` imports `my_fn` unqualified so you can call it without a prefix
-   Standard library modules follow the same convention:
    `import gleam/list`, `import gleam/dict`, `import gleam/string`
    -   [%g circular_import "Circular imports" %] are not allowed
-   If two dependencies both export a module named `utils`,
    there will be a name conflict
    -   `import a/utils as au` works as you'd expect

## This Lesson

-   `src/utils/types.gleam` contains shared type definitions
-   `src/utils/logic.gleam` contains pure functions over those types
-   `src/example.gleam` is the entry point that wires them together

## Public and Private Definitions

-   Every function and type in Gleam is private by default
    -   I.e., only visible in its own file
-   Adding `pub` makes it accessible from other modules

[%inc src/utils/types.gleam mark=status_todo %]

-   `pub type Status` exports the type and its constructors (`Active`, `Done`)
    -   Other modules can create `Active` or `Done` values
-   `pub type Todo` exports the record type and its constructor
    -   Other modules can write `Todo(title: "...", status: Active)`

[%inc src/utils/types.gleam mark=display_status %]

-   Use private functions for implementation details that callers should not depend on directly
    -   E.g., have a public entry point to start computing
        and a private function to do the recursion

## Opaque Types

-   An [%g opaque_type "opaque type" %] declared with `opaque`
    makes the type name public but hides its constructors
-   Other modules can hold a value of the type but cannot create or inspect it directly
    -   They must use the functions the module provides

[%inc src/utils/counter.gleam mark=counter_type %]

-   `Counter` is visible to other modules
-   `Counter(42)` is not: only `new()` can create a `Counter`
-   A common use is collections that enforce invariants
    -   E.g., sorted lists, non-empty lists, validated email addresses, etc.

## Organising by Layer

-   The `logic` module contains pure functions that take and return plain data:

[%inc src/utils/logic.gleam mark=add_task %]

-   `add_task` has no side effects: list in, list out
    -   Easy to test: call it, inspect the result
-   It uses `types.Todo` and `types.Active` because `utils/types` is imported at the top of the file
-   Prepending with `[new_item, ..existing]` is idiomatic: it runs in constant time

[%inc src/utils/logic.gleam mark=render %]

-   `render` is also pure: `List(Todo)` in, `String` out
-   `list.index_map(fn(i, task) { ... })` maps with a zero-based index
    -   Like Python's `enumerate`
-   `string.join("\n")` concatenates lines with a newline separator
-   Returning a `String` instead of printing keeps this function in the logic layer
    -   The caller decides how to display it
-   The three-layer structure:
    -   `types.gleam`: data definitions only, no logic
    -   `logic.gleam`: pure functions over the types, no IO imports
    -   Entry point: calls logic functions and handles side effects

## Testing with gleeunit

-   Gleam's test runner is `gleeunit`
-   Put tests in files named `*_test.gleam` in the `test/` directory

[%inc test/modules_test.gleam mark=test_examples %]

-   Every function ending in `_test` runs automatically
-   Use `should.equal` from `gleeunit/should` to assert that two values match:
    pipe the actual value into `|> should.equal(expected)`,
    and gleeunit reports a clear failure message if they differ
-   Use `should.be_true(condition)` or `should.be_false(condition)`
    when the result is already a `Bool`
    and there is no natural expected value to compare against
-   `gleam test` runs all tests, `gleam test --module foo_test` runs one file

## Type Aliases

-   `type MyAlias = SomeOtherType` creates a readable name for an existing type.

[%inc src/utils/aliases.gleam mark=type_aliases %]

-   `Filename` and `String` are identical to the compiler; one is just more descriptive
-   Unlike opaque types, aliases do not hide constructors
-   Type aliases are rarely used in ordinary Gleam code
    -   Their main practical use is to re-export an opaque internal type
        under a public name without exposing its constructors

## Check Understanding

<details markdown="1">
<summary markdown="1">Why separate logic from IO?</summary>

Pure functions are straightforward to test:
give them known inputs and check the outputs.
Functions that print to the screen, read files, or make network requests
require more setup to test reliably.
By keeping logic in a module that imports no IO modules,
you can test all the interesting behaviour with simple tests that do not touch the filesystem or terminal.
This pattern is sometimes called "functional core, imperative shell".

</details>

<details markdown="1">
<summary markdown="1">What makes a good unit test?</summary>

A good unit test is fast, isolated, and specific, and repeatable.
Fast: it should complete in milliseconds, with no network or disk access.
Isolated: it depends only on the function under test and its inputs.
Specific: when it fails, the failure message tells you exactly what went wrong.
Repeatable: it gives the same result every time
(which means it doesn't depend on the current time, a random number, or anything similar).
Pure functions in the logic layer are natural candidates because
they satisfy all three criteria automatically.

</details>

## Exercises

<div class="exercise" markdown="1">

### Opaque counter (10 minutes)

Define `pub opaque type Counter` with `new()`, `increment()`, `decrement()`, and `value()`.
Add a guard in `decrement` so the counter never goes below zero.
Write three gleeunit tests covering each operation.

</div>

<div class="exercise" markdown="1">

### Logic layer tests (10 minutes)

Write one unit test for each of `add_task`, `mark_done`, and `render`.
Each test must check a specific outcome.

</div>

<div class="exercise" markdown="1">

### Type alias clarity (5 minutes)

Add `type Title = String` and `type TaskIndex = Int` to `types.gleam`.
Update the signatures in `logic.gleam` to use them.
Confirm `gleam build` still succeeds.

</div>

<div class="exercise" markdown="1">

### Opaque stack (15 minutes)

Define `pub opaque type Stack(a)` in a new file `src/utils/stack.gleam`.
Implement `new() -> Stack(a)`, `push(Stack(a), a) -> Stack(a)`,
`pop(Stack(a)) -> Result(#(a, Stack(a)), Nil)`, and `size(Stack(a)) -> Int`.
`pop` should return `Error(Nil)` on an empty stack.
Write three gleeunit tests: one for `push`/`pop` round-trip,
one for popping an empty stack, and one for `size` after several pushes.

</div>

<div class="exercise" markdown="1">

### Filter active tasks (10 minutes)

Add a `filter_active(tasks: List(types.Todo)) -> List(types.Todo)` function
to `logic.gleam` that returns only tasks whose status is `Active`.
Write a gleeunit test that creates a list with both `Active` and `Done` tasks
and confirms only the active ones are returned.

</div>
