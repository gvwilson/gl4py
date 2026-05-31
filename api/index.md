# To-Do List Web API

<div class="callout" markdown="1">

-   A three-tier web service separates HTTP handling,
    business logic,
    and state management into independent layers.
-   The state tier is an OTP actor handling typed messages
    and is the single source of truth.
-   The logic tier is pure functions over `List(Todo)`,
    which is easy to test without a running server.
-   The HTTP tier routes requests, calls the actor, and encodes responses as JSON.
-   `gleam/json` encodes structured data;
    `gleam/dynamic` decodes untyped JSON bodies.
-   Use a database to ensure that data survive restarts.
-   Running migrations at startup keeps the schema versioned and reproducible.
-   Never interpolate user input into SQL strings.

</div>

## The Three-Tier Structure

-   Web applications benefit from clear separation between layers:
    -   State tier: holds mutable data; the only place writes happen
    -   Logic tier: pure functions that transform data
    -   HTTP tier: parses requests, calls logic, formats responses
-   In Gleam on the BEAM, the state tier is an [%g otp "OTP" %] [%g actor "actor" %]
-   The logic tier is ordinary functions with no imports from `gleam_otp` or `wisp`
-   The HTTP tier uses [Wisp][wisp] for routing and [Mist][mist] as the underlying HTTP server

## Types

[%inc src/todo_server.gleam mark=todo_types %]

-   `Todo` is the domain record: an integer ID, a title string, and a completion flag
-   `Msg` is the actor's message type: typed commands sent to the state tier
-   `GetAll` carries no data; the caller receives a reply on a `Subject`
-   `Add(String)` carries the new title
-   `MarkDone(Int)` and `Remove(Int)` carry the target ID

## Logic Tier

-   Use pure functions for the logic layer:

[%inc src/todo_server.gleam mark=logic_fns %]

-   `add` returns both the new item and the new list
    -   The caller can return the item to the client in the HTTP response
-   `mark_done` maps over the list and rebuilds the matching record with `done: True`
-   `remove` filters out the matching record
-   None of these functions touch IO or the actor;
    they can be tested with plain gleeunit

## JSON Encoding

[%inc src/todo_server.gleam mark=encode_fn %]

-   `json.array(list)` encodes a list of JSON values as a JSON array
-   `json.object([#(key, value), ...])` encodes a record as a JSON object
-   `json.int`, `json.string`, `json.bool` wrap Gleam values
-   `json.to_string` serializes the entire structure to a `String`

The resulting JSON looks like:

```json
[
  {"id":0,"title":"learn Gleam","done":true},
  {"id":1,"title":"build API","done":false}
]
```

## HTTP Routes

-   In a full Wisp application the router dispatches on method and path:

[%inc snippets/router.gleam mark=router_fn %]

-   `wisp.path_segments` splits the URL path into a list of strings
-   Pattern matching on the list handles both fixed paths (`"todos"`)
    and paths with parameters (`"todos", id_str`)
-   `wisp.method_not_allowed` returns a [%g http_405 "405 response" %]
    with the `Allow` header set

## JSON Decoding

-   Parsing the `POST` body requires decoding an untyped JSON value:

[%inc snippets/router.gleam mark=decode_body_fn %]

-   `dynamic.field("title", dynamic.string)` extracts the `"title"` field
    and asserts it is a string
-   The return type `Result(String, List(DecodeError))`
    forces the caller to handle missing or wrongly-typed fields
-   Composing field decoders with `dynamic.decode2` or `dynamic.decode3`
    handles records with multiple fields

## Adding a Database

-   The actor's `List(Todo)` disappears when the process restarts
-   Replacing it with [SQLite][sqlite] or some other database makes data survive restarts
    and supports indexed queries that would be expensive over an in-memory list
-   The HTTP routes and JSON encoding do not change; only the storage layer changes
-   Open the database at startup and pass the connection to the actor:

[%inc snippets/db.gleam mark=insert_todo_fn %]

-   `sqlight.text(title)` and `sqlight.int(0)` wrap parameters as SQL values
-   `?` placeholders are replaced in order
-   Never interpolate user input directly into SQL strings
    -   Doing so enables [%g sql_injection "SQL injection attacks" %]

## Row Decoder

-   Each result row arrives as `Dynamic`
-   A decoder extracts columns by index:

[%inc snippets/db.gleam mark=row_decoder_fn %]

-   `dynamic.element(0, dynamic.int)` reads column 0 as an integer
-   `done == 1` converts SQLite's integer `0`/`1` to `Bool`
-   `dynamic.decode3` assembles the three columns using the constructor

## Migrations

-   A [%g database_migration "migration" %] is a SQL script that changes the schema
    without losing data
-   Running all migrations at startup ensures the database is always in the expected state:

[%inc snippets/db.gleam mark=migrations_fn %]

-   `CREATE TABLE IF NOT EXISTS` makes the migration [%g idempotent "idempotent" %]
    -   So it is safe to run against an existing database
-   New schema changes are always appended as new entries
    -   Existing migrations are never modified
-   Opening `:memory:` in tests gives a fresh database per test with no cleanup required

## Testing

[%inc test/api_test.gleam mark=tests %]

-   All tests exercise the logic tier directly
    -   no HTTP or actor setup needed
-   `add_creates_item_test` checks that the returned item has the right title
    and that `done` starts as `False`
-   `mark_done_updates_flag_test` confirms that only the targeted item changes
-   `remove_deletes_item_test` confirms the list shrinks by one

## Check Understanding

<details markdown="1">
<summary markdown="1">What is SQL injection and why do parameterised queries prevent it?</summary>

SQL injection occurs when user-supplied input is concatenated directly into a SQL string.
A title like `"'; DROP TABLE todos; --"` would execute a `DROP TABLE` statement if interpolated naively.
Parameterised queries send the query and the parameters separately.
The database driver handles escaping,
so user input is never interpreted as SQL syntax.
Always use `?` placeholders:
never build SQL strings by interpolating user input.

</details>

<details markdown="1">
<summary markdown="1">Why use an OTP actor for state rather than a global variable?</summary>

Gleam has no global mutable variables,
so all state must live somewhere explicit.
An OTP actor is a process that owns its state:
only the actor reads or writes it, so there is no need for locks.
Other processes send messages and receive replies;
the actor serializes concurrent requests automatically.
If the actor crashes,
the supervisor restarts it,
so no other process is affected.
This "share nothing" model is why BEAM applications can run for years.

</details>

<details markdown="1">
<summary markdown="1">The logic tier has no imports from `wisp` or `gleam_otp`.
Why does that matter for testing?</summary>

Because the logic functions are pure:
they take data in and return result with no side effects and no external dependencies.
Tests can call `add`, `mark_done`, and `remove` directly with plain `List(Todo)` values,
without starting a server, an actor, or a network socket.
Keeping business logic in a layer that has no framework dependencies is
what makes unit testing fast and reliable.

</details>

## Exercises

<div class="exercise" markdown="1">

### Mark done route (15 minutes)

Add `PATCH /todos/:id` that marks an item as done.
Update `Msg` with `MarkDone(Int)`, add a logic function, and add a Wisp handler.
Write a test that posts an item and then patches it.

</div>

<div class="exercise" markdown="1">

### Input validation (10 minutes)

Reject a `POST` with an empty title (`""`) and return `400 Bad Request`.
Add this check in the HTTP tier (after decoding), not in the logic tier.
Write a test confirming the 400 response.

</div>

<div class="exercise" markdown="1">

### Priority field (20 minutes)

Add `type Priority { High  Medium  Low }` and a `priority` field to `Todo`.
Update encoding (use `json.string(priority_to_string(p))`)
and decoding (parse the string back to a variant),
and add tests.

</div>

<div class="exercise" markdown="1">

### Filter by status (10 minutes)

Add `GET /todos?done=true` that returns only completed items.
Use `wisp.get_query` to read the query parameter and filter the list in the logic tier.
Write tests for both `?done=true` and `?done=false`.

</div>

<div class="exercise" markdown="1">

### SQLite persistence (20 minutes)

Replace the actor's `List(Todo)` with a `sqlight.Connection`.
Update `Add`, `MarkDone`, and `Remove` to run parameterised queries.
Use `sqlight.open(":memory:")` in tests so each test starts with a fresh database.
Confirm that the same HTTP-tier tests still pass without modification.

</div>

<div class="exercise" markdown="1">

### Transactional batch insert (20 minutes)

Write `insert_many(conn: Connection, titles: List(String)) -> Result(List(Todo), String)`.
Wrap all inserts in a transaction: `BEGIN`, insert each, `COMMIT`.
If any insert fails, `ROLLBACK` and return an `Error`.
Write a test that confirms a failed batch leaves no partial data.

</div>
