# HTTP API Client with JSON Decoding

<div class="callout" markdown="1">

-   `gleam/dynamic/decode` provides composable decoders that convert
    untyped external data into typed Gleam values.
-   A `decode.Decoder(t)` is built with `decode.field` and the `use` syntax;
    decoders compose by nesting.
-   Separating the fetch step from the decode step keeps each part independently testable.
-   `json.parse(string, decoder)` parses a JSON string and runs the decoder in one call.
-   Network errors, non-200 responses, and decode failures are all `Result` errors;
    the caller handles them uniformly.

</div>

## The Problem

-   External APIs return JSON: untyped text with no compile-time guarantees
-   To work with the data in a type-safe way, you need to decode it into your own types
-   `gleam/dynamic/decode` provides a decoder [%g dsl "domain-specific language" %] (DSL)
    -   Small functions that each handle one piece of a JSON structure
-   Composing them produces a decoder for the whole record,
    and the compiler checks the composition

## The Issue Type

[%inc src/decode_demo.gleam mark=issue_type %]

-   A GitHub issue has many fields; this decoder extracts only three
-   The type definition says exactly what the application cares about
-   Fields not listed are silently ignored by the decoder

## Writing a Decoder

[%inc src/decode_demo.gleam mark=decoder_fn %]

-   `issue_decoder()` returns a `decode.Decoder(Issue)`
-   `decode.field("number", decode.int)` reads the `"number"` key
    and decodes it as an integer
    -   `decode.int` and `decode.string` are built-in decoders
-   The `use` bindings run in sequence
    -   If any field is missing or has the wrong type the whole decoder returns an error
-   `decode.success(Issue(...))` assembles the value only when all fields decoded successfully

## Decoding a JSON String

[%inc src/decode_demo.gleam mark=decode_fn %]

-   `decode.list(issue_decoder())` wraps the single-item decoder
    to handle a JSON array
-   `json.parse` parses the string and runs the decoder
-   `string.inspect` converts the decode error to a human-readable string
    for display or logging

## Making HTTP Requests

-   In a real application, `gleam_httpc` fetches the data:

[%inc snippets/httpc_demo.gleam mark=fetch_issues_fn %]

-   Network errors produce `Error` immediately
-   Non-200 status codes produce `Error` with the status
-   Only a 200 response is decoded; the logic is layered explicitly

## Testing the Decoder

[%inc test/client_test.gleam mark=tests %]

-   The decoder can be tested with a hard-coded JSON string: no network needed
-   `decode_one_issue_test` confirms the happy path
-   `missing_field_test` confirms that a missing `"state"` field returns an error
-   `wrong_type_test` confirms that a non-integer `"number"` returns an error

## Check Understanding

<details markdown="1">
<summary markdown="1">What is a `Dynamic` value?</summary>

Gleam is statically typed: every value has a known type at compile time.
But JSON is dynamically typed:
the structure of a JSON blob is not known until you parse it at runtime.
`decode.Decoder(t)` is a description of how to extract a `t` from untyped data;
it is not a function you call directly.
`json.parse(string, decoder)` feeds the parsed JSON into the decoder
and returns `Ok(value)` or `Error(dynamic.DecodeErrors)`.
Once the decoder succeeds,
the value is fully typed and the compiler enforces it.
This is similar to `json.loads` in Python,
but with the parsing and type-checking fused into one step.

</details>

<details markdown="1">
<summary markdown="1">Why test the decoder with a hard-coded JSON string instead of making a real HTTP request?</summary>

Testing against a live network introduces failures that have nothing to do with your code:
the server might be down, rate-limit you, or return different data each time.
A hard-coded string makes the test deterministic and fast.
The decode step and the fetch step are deliberately separated so each can be tested alone.
Once you are confident the decoder is correct, integration tests can cover the network layer;
but unit tests should never depend on external services.

</details>

## Exercises

<div class="exercise" markdown="1">

### Labels field (15 minutes)

Add a `labels: List(String)` field to `Issue`.
The GitHub API returns it as an array of objects with a `"name"` field.
Write a decoder for the label object, then compose it with `decode.list`
and add it to `issue_decoder`.
Update the tests.

</div>

<div class="exercise" markdown="1">

### Filter open issues (10 minutes)

Write `open_issues(issues: List(Issue)) -> List(Issue)` that only returns
issues where `state == "open"`.
Add tests with a mix of open and closed issues.

</div>

<div class="exercise" markdown="1">

### Retry on 5xx (15 minutes)

Modify `fetch_issues` to retry once if the response status is >= 500.
The function signature does not change.
Write a test using a hard-coded response that simulates a 500 followed by a 200.

</div>

<div class="exercise" markdown="1">

### Repository decoder (20 minutes)

Write `type Repo { Repo(name: String, stars: Int, language: String) }`
and a decoder for `GET /repos/:owner/:repo`.
The GitHub API uses `"stargazers_count"` for stars and `"language"`
for the primary language.
Use `decode.field` for each field,
following the same `use` pattern as `issue_decoder`.

</div>
