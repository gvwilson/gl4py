# Getting Started, Types, and Values

<div class="callout" markdown="1">

-   "Let" bindings are immutable:
    once you bind a name to a value, that binding cannot change.
-   Custom types describe the shape of your data
    and let the compiler verify that you have handled every case.
-   Records group named fields into a single value, like a Python dataclass.
-   Tuples hold a fixed number of values of different types.

</div>

## Hello, World

-   Every Gleam project starts with `gleam new`
    -   Creates a project directory with a source file, a test file, and a `gleam.toml`

[%inc gleam.toml %]

-   Use `gleam run` to compile and execute the default entry point

[%inc src/hello.gleam %]
[%inc out/hello.out %]

-   `import gleam/io` makes the `io` module available
-   `pub fn main()` is the entry point
    -   `pub` (public) makes it visible outside the module
    -   `fn` is short for "function"
-   `let name = "Gleam"` creates an [%g immutable "immutable" %] binding
    -   All bindings are final: reassigning a name is a compile error
-   `<>` concatenates strings
    -   Gleam does not overload `+` to add strings
-   `io.println` prints a line with a newline
    -   `echo` prints any value using its debug representation

## Arithmetic

[%inc src/arithmetic.gleam mark=arithmetic %]
[%inc out/arithmetic.out %]

-   `2 + 2` is integer arithmetic
    -   The result is `Int`, not `Float`
-   Gleam separates integer and floating-point operators:
    `+`, `-`, `*`, `/` for `Int`; `+.`, `-.`, `*.`, `/.` for `Float`
    -   `int.to_float` converts before you can mix them
-   Integer division by zero (and modulo by zero) returns 0
    rather than raising an error
    -   This is different from Python, where `1 / 0` raises `ZeroDivisionError`
-   These rules seem pedantic, but they are consistent

## Built-in Types

-   Gleam's primitive types map directly to Python equivalents
-   But the type system prevents you from mixing them
-   `Int`: arbitrary-precision integer, like Python's `int`
-   `Float`: 64-bit floating-point, like Python's `float`
-   `String`: UTF-8 text, like Python's `str`
-   `Bool`: `True` or `False`, like Python's `bool`
-   `Nil`: the unit value, similar to Python's `None` but much rarer
-   Other types built into the language
    (introduced in later lessons) include:
    -   `List(a)` for sequences of values of the same type
    -   `Result(a, e)` for operations that can succeed or fail
    -   `BitArray` for binary data at the bit level
    -   `UtfCodepoint` for individual Unicode characters

## Custom Types

-   Most important building block in Gleam is the [%g custom_type "custom type" %]
-   packages one or more [%g named_variant "named variants" %] into a single type

[%inc src/types.gleam mark=type_defs %]

-   `type Color { Red Green Blue }` defines a type with three variants
    -   Like a Python `Enum`, but integrated into the type system
    -   `Red`, `Green`, `Blue` are constructors, not strings
-   `type Shape { Circle(Float) Rectangle(Float, Float) }` defines variants that carry data
    -   `Circle(Float)` is like a Python dataclass with one float field
    -   `Rectangle(Float, Float)` has two float fields
    -   The compiler knows exactly which fields each variant carries
-   There is no inheritance: custom types are closed and complete
-   Now a function that uses the type:

[%inc src/types.gleam mark=area_fn %]
[%inc out/types.out %]

-   `case shape { ... }` matches on the value of `shape`
-   Each arm extracts fields, e.g., `Circle(r)` binds the radius to `r`
-   The compiler verifies that every variant is handled
    -   Remove the `Rectangle` arm and the compiler reports an error
    -   Python's `if isinstance` chains have no such guarantee
-   The last expression in each arm is the arm's value: no `return` needed
-   `3.14159 *. r *. r` uses `*.` because `r` is a `Float`
    -   Yes, we will get π from a library the next time

## Records with Named Fields

-   When a variant carries several fields, naming them makes the code clearer

[%inc src/icecream.gleam mark=icecream_type %]

-   `IceCream(flavor: Flavor, container: Container)` defines a variant with named fields
    -   `flavor: Flavor` means the field named `flavor` holds a `Flavor` value
    -   Access fields with dot notation: `item.flavor`, `item.container`
-   `Flavor` and `Container` are separate custom types defined above `IceCream`
    -   This is like a Python dataclass whose field types are enums
-   Creating a value with named fields: `IceCream(flavor: Chocolate, container: Cone)`
    -   You can also write `IceCream(Chocolate, Cone)` when the order is unambiguous

[%inc src/icecream.gleam mark=display_fn %]
[%inc out/icecream.out %]

-   `item.flavor` and `item.container` access named fields using dot notation
-   `flavor_string` and `container_string` are private helper functions (no `pub`)
-   The `<>` operator chains string concatenation left to right

## Tuples

-   A [%g tuple "tuple" %] groups a fixed number of values of potentially different types
-   Gleam writes tuples with a `#` prefix: `#(1, "hello", True)`

[%inc src/tuples.gleam mark=tuple_create %]

-   `#(1, "hello", True)` creates a tuple of type `#(Int, String, Bool)`
-   The type is inferred: you do not need to write it explicitly
-   As in Python,
    tuples are useful for returning multiple values from a function

[%inc src/tuples.gleam mark=tuple_destruct %]
[%inc out/tuples.out %]

-   `let #(a, b, c) = t` [%g destructuring "destructs" %] the tuple into three bindings
    -   `a` is `1`, `b` is `"hello"`, `c` is `True`
    -   Like Python's `a, b, c = t` but the `#` makes clear a tuple is expected
-   Gleam does have indexed tuple access using dot notation:
    `tuple.0` for the first element, `tuple.1` for the second, etc.
    -   Destructuring is the idiomatic way to extract tuple fields

## Type Inference

-   Gleam almost never requires you to write type annotations
-   The compiler infers the type of every expression from context
    -   `let x = 42` infers `x: Int`
    -   `let s = "hello"` infers `s: String`
    -   `fn area(shape: Shape) -> Float` carries explicit annotations,
         but they are optional for local bindings
-   Gleam's official recommendation is to annotate all public top-level
    definitions (exported functions and custom type variants)
    -   The compiler checks annotations against the inferred type
        and reports a mismatch as an error

```gleam
let x: Int = 42
let name: String = "Gleam"
```

## Check Understanding

<details markdown="1">
<summary markdown="1">What is the difference between `+` in Python and Gleam?</summary>

Python uses a single `+` for both integers and floats and silently coerces between them,
and uses `+` to concatenate strings as well.
Gleam requires you to be explicit:
`+` for integers, `+.` for floats, and `<>` for strings.
This makes mixed-type arithmetic a compile error rather than a runtime surprise.
The practical consequence is that you must call `int.to_float` before combining an integer with a float.

</details>

<details markdown="1">
<summary markdown="1">What happens if you forget to handle a variant in a case expression?</summary>

The compiler produces an error before the program runs.
Every `case` expression in Gleam must be exhaustive,
i.e., it must handle every variant of the type being matched.
This is one of the most practical benefits of the type system:
you cannot accidentally omit a case and discover the gap in production.
Python has no equivalent guarantee:
a missing `elif` or `isinstance` branch fails silently until the code runs.

</details>

## Exercises

<div class="exercise" markdown="1">

### Hello with arithmetic (5 minutes)

Create a new Gleam project.
In `main`,
bind your name to a variable and print a greeting that includes it.
Also print the result of `10 * 10 - 1` and the result of dividing `22.0` by `7.0`.

</div>

<div class="exercise" markdown="1">

### Echo

Look up what `echo` does in Gleam,
then convert one of the examples in this lesson to use it instead of `io.println`.
How much do you miss Python's `print` function?

</div>

<div class="exercise" markdown="1">

### Ice cream order (10 minutes)

Using the `IceCream` type from `icecream_demo.gleam`, write
`describe(item: IceCream) -> String` that returns a sentence like
`"Chocolate ice cream in a cone"`.
Create three orders and print their descriptions.

</div>

<div class="exercise" markdown="1">

### Shape functions (10 minutes)

Write `perimeter(shape: Shape) -> Float` that returns `2 * pi * r` for a circle
and `2 * (w + h)` for a rectangle.
Also write `describe(shape: Shape) -> String`
that returns a human-readable description like `"circle with radius 3.0"`.

</div>

<div class="exercise" markdown="1">

### Tuple swap (5 minutes)

Write `swap(pair: #(a, b)) -> #(b, a)` that returns a new tuple with the two elements reversed.
Gleam will infer the generic types `a` and `b` automatically.
Test it with `#(1, "one")` and `#(True, 42)`.

</div>

<div class="exercise" markdown="1">

### Public vs. private types (5 minutes)

In `src/types.gleam`, the `Color` type is declared `pub type Color`.
Remove the `pub` keyword so it reads `type Color`,
then run `gleam run --module types`.
What warning does the compiler produce, and why?

</div>
