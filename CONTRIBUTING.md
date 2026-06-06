# Contributing

Contributions are very welcome;
please contact us [by email][email] or by filing an issue in [our repository][repo].
All contributors must abide by our Code of Conduct.

## Contributors {: #contributors}

[*Greg Wilson*][wilson_greg] is a programmer, author, and educator based in Toronto.
He was the co-founder and first Executive Director of Software Carpentry
and received ACM SIGSOFT's Influential Educator Award in 2020.

## FAQ

Do you need help?
:   Yes—please see the issues in [our repository][repo].

What sort of feedback would be useful?
:   Everything is welcome,
    from pointing out mistakes to suggestions for better explanations.

Can I add a new section?
:   Possibly, but please [reach out][email] before doing so.

Why is this material free?
:   Because if we all give a little, we all get a lot.

## Setup and Operation

-   Install [uv][uv].
-   Create a virtual environment by running `uv venv` in the root directory.
-   Activate it by running `source .venv/bin/activate` in your shell.
-   Install dependencies by running `uv sync`.
-   Run `task --list` to see a list of tasks.

## Writing Style

These rules apply to all lesson prose.

-   Write in a conversational tone.
    Rely on anecdotes about specific events rather than abstract generalizations.
-   Use the active voice wherever possible.
-   Readers are intelligent and have large vocabularies,
    but are not familiar with specialist terms beyond
    what they would learn in high school classes.
-   Do not use bold in prose.
    Use italics sparingly, and only for emphasis or introducing a term.
-   Use four-space indentation in bullet lists:
    a dash and three spaces for top-level items,
    four spaces then a dash and three spaces for nested items.
-   Do not use tab characters anywhere in Markdown files.
-   Use semicolons and em-dashes sparingly.
    Never write `---` in prose; if an em-dash is truly needed,
    use the actual character (—) with no spaces around it.
-   Do not attempt to be funny or offer generic positive feedback to readers.
-   Each lesson must include citations or links for further reading.
    Use `[text][key]` for external links and define `key` in `_extras/links.md`.

## Lesson Structure

-   Each lesson lives in its own directory (`lessonname/index.md`).
-   The lesson order is defined in `README.md`.
-   Start each lesson with a `<div class="callout">` listing the three to five
    key takeaways as bullet points.
-   Write self-test questions as `<details>` blocks
    (see any existing lesson for the exact format).
-   Write exercises under an H2 heading named `Exercises`.
    Wrap each exercise in `<div class="exercise">` and include a time estimate
    in parentheses in the H3 heading.
-   Reference glossary terms with `[%g key "display text" %]`.
-   Reference bibliography entries with `[%b Key1 Key2 %]`.

## Gleam Code Style

All Gleam source files live in `lessonname/src/` and their captured output in `lessonname/out/`.

-   Run `gleam format` on every `.gleam` file before committing.
    The CI check will fail if any file does not pass `gleam format --check`.
-   All `gleam.toml` files must specify `gleam_stdlib = ">= 1.0.0 and < 2.0.0"`.
    Do not use `>= 0.34.0`; that range predates the stable 1.0 release.
-   Annotate all public top-level functions and types with explicit type signatures.
    Type inference is fine for local bindings and private helpers.
-   Use meaningful variable names.
    Write `items` instead of `lst`, `numerator` and `denominator` instead of `a` and `b`
    when the names carry meaning, and avoid single-letter names except for
    genuinely generic type parameters (`a`, `b`) and short mathematical expressions.
-   Prefer `int.to_string`, `float.to_string`, and similar concrete conversion functions
    over `string.inspect` when printing known types.
    Reserve `string.inspect` for debugging values whose type is not known statically.
-   Do not use `io.debug`; it was removed from the standard library.
    Use `echo` for quick debug printing or `io.println` with an explicit conversion.
-   Write tests using the `assert` keyword.
    The `gleeunit/should` module is deprecated; do not use `should.equal`,
    `should.be_ok`, or any other function from it.
-   Prefer custom error enum types over `String` as the error type in `Result`.
    A custom type lets the compiler verify that every error case is handled.
-   Use `Option` for optional record fields and optional parameters.
    For return types that can fail, prefer `Result`,
    which can carry an error description.
-   Use `result.try` for chaining fallible operations.
    `result.map` is for single-step transformations;
    `result.map_error` transforms the error side;
    `result.unwrap` extracts a value with a fallback.
-   Use the `use` expression when chaining three or more fallible operations.
    For one or two operations, a `case` expression is usually clearer.
-   Type aliases are rarely useful in normal code.
    Their main purpose is re-exporting opaque internal types from a module.
    Do not introduce type aliases just for readability.

[email]: mailto:gvwilson@third-bit.com
[repo]: https://github.com/gvwilson/gl4py
[uv]: https://github.com/astral-sh/uv
[wilson_greg]: https://third-bit.com/
