# Glob Pattern Matcher

<div class="callout" markdown="1">

-   Shell-style glob patterns like `*.gleam` and `data?.csv`
    can be represented as lists of typed elements.
-   We can parse the usual string representation to create such lists.
-   Recursive pattern matching consumes one element at a time.
-   The `Wildcard` case requires backtracking:
    try skipping the wildcard, and if that fails,
    consume one input character and try again.
-   Use `gleeunit`  to write unit tests for Gleam.

</div>

## The Problem

-   Command-line shells use patterns like `*.gleam`, `data?.csv`, and `report_2024*`
    to match groups of filenames
    -   These patterns are called [%g glob "globs" %] (short for "global")
-   Three rules cover everything a basic glob matcher needs:

-   `*` matches any sequence of characters, including the empty sequence
-   `?` matches any single character
-   Everything else matches exactly itself

-   Writing a glob matcher uses custom types, recursion, and pattern matching
    in a single small program

## Representing Pattern Elements

-   First design decision is how to represent a parsed pattern
-   A `String` would lose the structure:
    we could not easily tell a literal asterisk from a wildcard metacharacter.
-   A custom type makes each case explicit:

[%inc src/match_demo.gleam mark=elem_type %]

-   `Literal(String)` holds a single character that must match exactly
-   `AnyChar` matches any one character and holds no data
-   `Wildcard` matches zero or more characters and holds no data
-   Adding a new rule (e.g., character classes) means adding a new variant,
    and the compiler will flag every `case` that does not handle it
-   `List(Elem)` is the natural representation for a whole pattern
    -   `[Wildcard,  Literal(".gl")]` represents `*.gl`
-   Get matching to work, then build a parser to turn strings into these lists

## Matching a Pattern Against Text

-   Matching consumes elements and characters in parallel:

[%inc src/match_demo.gleam mark=match_fn %]

-   `match_pattern` converts the input string to a list of graphemes
     and delegates to `match_pattern_chars`
-   `match_pattern_chars` [%g dispatch "dispatches" %] on the pair `(pattern, chars)`:
    -   Both empty: success
    -   Pattern empty but input remains: failure (we required more)
    -   `Literal(c)` with a matching character: advance both and recurse
    -   `AnyChar` with any character: advance both and recurse
    -   `Wildcard`: the two-branch case described below
    -   Anything else (literal mismatch, empty input when pattern not empty): failure

## Handling Wildcards

-   The `Wildcard` branch is the most interesting one
-   A wildcard can match zero characters (the pattern continues from the same position)
    or one or more characters (the input advances by one)
-   The code tries the zero-match option first:

```gleam
[Wildcard, ..pat_rest], _ -> {
  case match_pattern_chars(pat_rest, chars) {
    True -> True
    False -> {
      case chars {
        [] -> False
        [_, ..char_rest] -> match_pattern_chars(pattern, char_rest)
      }
    }
  }
}
```

-   Try `match_pattern_chars(prest, chars)`:
    does the rest of the pattern match the current input
    without consuming anything for the wildcard?
-   If yes, return `True`
-   If no and input is exhausted, return `False`
-   If no and input remains,
    consume one character and retry with the same pattern
    -   The wildcard is still active

-   This is [%g depth_first_backtracking "depth-first backtracking" %]
-   For most practical inputs it is fast enough
    -   Pathological patterns like `*a*a*a*a*a*b` against a long string of `a`s can be slow,
        but that is a known trade-off in backtracking matchers

## Parsing Patterns

-   `src/match_demo.gleam` constructs pattern lists by hand
-   For real use we need a function that turns `"*.gleam"` into `[Wildcard, Literal(".gleam")]`

[%inc src/parse_demo.gleam mark=parse_fn %]

-   `parse_pattern` converts the string to graphemes and calls the recursive `parse_chars`
    -   This pattern of "entry point function calls recursive function" is used a *lot*
-   `parse_chars` accumulates elements in reverse and reverses at the end
-   `"*"` becomes `Wildcard`, `"?"` becomes `AnyChar`
-   Consecutive non-special characters are collected into a single `Literal` by `take_literal`
    -   Prevents `Literal("h")`, `Literal("e")`, `Literal("l")`, `Literal("l")`, `Literal("o")`
-   Notice that `Literal` holds a `String`, not a `UtfCodepoint`
    -   This lets one `Literal` represent a multi-character run,
        which is more efficient and easier to read in debug output

## Running the Examples

[% inc parse_demo.sh %]
[% inc out/parse_demo.out %]

-   The first three test `*.gleam` against:
    -   `hello.gleam` (match)
    -   `hello.rs` (no match)
    -   `.gleam` (match, because `*` can match zero characters)
-   The last three test `d?t` against:
    -   `dot` (match)
    -   `dat` (match)
    -   `dog` (no match, the `t` is missing)

## Writing Tests

-   Create `test/glob_test.gleam`:

[%inc test/glob_test.gleam mark=examples %]

-   Each test covers exactly one behavior
-   Test names end in `_test` so gleeunit discovers them automatically
-   `should.be_true()` and `should.be_false()` are clearer than `should.equal(True)` for Boolean results
-   Run with `gleam test`

## Filtering a List of Files

Combining the parser and matcher gives a useful utility:

[%inc src/filter_demo.gleam mark=filter_fn %]

-   `match_pattern(elems, _)` is a [%g partial_application "partial application" %]:
    it creates a one-argument function that tests a single filename
-   `list.filter` applies it to every element
-   `parse_pattern` runs once, while `List(Elem)` is reused for every file
-   This is an example of using a function value as data
    -   `list.filter` expects `fn(String) -> Bool`
    -   Partial application produces exactly that without writing a named helper function

## Check Understanding

<details markdown="1">
<summary markdown="1">Why does wildcard try zero characters first?</summary>

If the wildcard tried consuming a character first,
a pattern like `*x` against `"x"` would fail:
the wildcard would consume `x`,
leaving nothing for the literal `x` to match.
Trying zero first means a wildcard only uses up characters
when the rest of the pattern cannot match without them.

</details>

<details markdown="1">
<summary markdown="1">Why does `parse_chars` prepend to `acc` and call `list.reverse` at the end rather than appending each element?</summary>

Gleam lists are singly-linked, so prepending (`[elem, ..acc]`) is O(1):
it just creates a new node pointing at the existing list.
Appending to the end, by contrast, requires walking the whole list to find the last node,
making each append O(n) and the full parse O(n²).
Building the list in reverse with prepend and reversing once at the end keeps the total work O(n).

</details>

## Exercises

<div class="exercise" markdown="1">

### Parse integration (15 minutes)

Wire `parse_pattern` to `filter_files`
so the function accepts a `String` pattern rather than a `List(Elem)`.
Write gleeunit tests for `filter_files` that cover:
-   an empty file list
-   a pattern that matches no files
-   a pattern that matches all files
-   a mixed result

</div>

<div class="exercise" markdown="1">

### Character sets (20 minutes)

Add a `CharSet(List(String))` variant to `Elem`.
A `CharSet` matches any single character that appears in its list,
so `CharSet(["a", "e", "i", "o", "u"])` matches any vowel.
Update `match_pattern_chars` to handle the new variant.
Write at least four tests.

</div>

<div class="exercise" markdown="1">

### Negated character sets (15 minutes)

Add `NegCharSet(List(String))` that matches any character *not* in the list.
Update the matcher and write tests confirming that
it does not match characters in the list
but does match characters outside it.

</div>

<div class="exercise" markdown="1">

### Anchor to start and end (10 minutes)

Shell globs implicitly match anywhere unless anchored.
Add `Start` and `End` variants that require the match to begin at the first character
and end at the last character respectively.
Update `match_pattern` (not just `match_pattern_chars`) to interpret them.

</div>
