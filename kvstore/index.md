# Log-Structured Key-Value Store

<div class="syllabus" markdown="1">

-   An append-only log records every `Set` and `Delete` operation as an immutable entry.
-   Looking up the current value of a key requires scanning the log for the most recent entry.
-   A `Delete` entry acts as a tombstone,
    invalidating all earlier entries for the same key.
-   Compaction folds the log into a `Dict` to produce a minimal
    equivalent log with no shadowed entries.

</div>

## The Log-Structured Idea

-   Most databases that need high write throughput use an append-only design
    -   Instead of updating a value in place,
        every change is written as a new record at the end of a file
-   Reads scan the log to find the most recent write for a given key
    -   Start with the most recent entry and work backward to find a match
-   Old records are periodically [%g compaction "compacted" %] to save storage

## The Entry Type

-   Every operation on the store is one of two things:

[%inc src/log_demo.gleam mark=entry_type %]

-   `Set(key, value)` stores a value under a key
-   `Delete(key)` removes a key
-   Both variants carry `String` fields with labels
    so they can be accessed by name (`entry.key`) as well as by pattern matching
-   The entire store state is `List(Entry)`
-   This is an [%g event_log "event log" %]
    -   The log is never modified, only extended
-   Functions that query the store take the log as an argument

## Reading from the Log

-   To look up a key, scan from the beginning and return the first matching entry:
    -   Start at the beginning because new entries are prepended

[%inc src/log_demo.gleam mark=get_fn %]

-   `get` is a thin wrapper; `get_scan` does the recursion
-   `[Set(k, v), ..rest] if k == key -> Some(v)`:
    the  guard checks the key, and if it matches, returns the value immediately
-   `[Delete(k), ..rest] if k == key -> None`:
    the key was deleted, so `None` is correct even if earlier entries set it
-   `[_, ..rest] -> get_scan(rest, key)`:
    skip this entry and keep scanning

-   The return type is `Option(String)`
    -   `None` means the key is not in the store (either never set or deleted)
-   This is O(n) per read in the worst case
    -   That is acceptable for a demo
    -   In production, maintain an in-memory index so reads are O(1) — see the next section

## Indexed Lookup

-   Scanning the log on every read is O(n)
-   Building a `Dict` index makes each lookup O(1):

[%inc src/log_demo.gleam mark=index_fns %]

-   `build_index` folds the reversed log (oldest-first) into a `Dict(String, String)`,
    keeping only the most recent value for each live key
-   `get_indexed` wraps `dict.get`: O(1) per call
-   Build the index once when the log is loaded;
    rebuild it after any write

## Listing Live Keys

The `keys` function returns all keys that currently have a value:

[%inc src/log_demo.gleam mark=keys_fn %]

-   The fold threads a `Dict(String, Bool)` through the log
-   `Set` inserts the key; `Delete` removes it
-   `dict.keys` extracts the surviving keys
-   This is O(n) in the log length and O(k) in the number of live keys

## Compaction

-   A long-running store accumulates many [%g shadowed_entry "shadowed entries" %]
-   Compaction replaces the full log with a minimal equivalent one:

[%inc src/log_demo.gleam mark=compact_fn %]

-   The log is reversed so that the most recent entry for each key comes first when folding
-   `dict.insert` for a `Set` records the latest value
    -   If the key was already seen (i.e., there was a later entry) it is overwritten
    -   Which is fine because we want the latest value
-   `dict.delete` for a `Delete` removes the key
-   After the fold, the dict contains only the live key-value pairs
-   `dict.to_list` converts it back to `(k, v)` pairs wrapped in `Set`
-   After compaction, `Delete` entries disappear
    -   They have already been applied by removing the key from the dict

## Serialisation

-   To persist the log across restarts, each entry is written as a text line:

[%inc src/persist_demo.gleam mark=persist_fn %]

-   `"SET|key|value"` encodes a `Set` entry; `|` separates the fields
-   `"DEL|key"` encodes a `Delete` entry
-   `parse_lines` reverses the process using `string.split(line, "|")`
    and pattern matching on the resulting list
-   In production code, writing to a file uses `simplifile.write_bits` or `simplifile.append`

## Testing

[%inc test/kvstore_test.gleam mark=tests %]

-   All tests use an in-memory `List(Entry)`; no file I/O needed
-   Each log is newest-first: the most recently written entry is at the front of the list
-   `overwrite_test` verifies that the entry at the front of the list wins
-   `delete_test` confirms that a `Delete` at the front returns `None`
    even though an earlier `Set` exists later in the list

## Check Understanding

<details markdown="1">
<summary markdown="1">A log contains ten entries, all setting key `"x"` to different values.
After calling `compact`, how many entries does the result contain for `"x"`, and why?</summary>

One entry.
`compact` folds the reversed log into a `Dict`, so each key appears at most once.
The fold processes entries from oldest to newest;
`dict.insert` overwrites on each call, so the newest value wins.
All earlier entries for `"x"` are shadowed and discarded.

</details>

<details markdown="1">
<summary markdown="1">The log `[Delete("x"), Set("x", "1")]` is newest-first.
What does `get(log, "x")` return?
What would it return if the list were reversed to `[Set("x", "1"), Delete("x")]`,
and what real-world operation sequence does each order represent?</summary>

For `[Delete("x"), Set("x", "1")]`, `get` returns `None`:
`get_scan` matches `Delete("x")` at the head and stops immediately.
This represents: key `"x"` was set first, then deleted.

For `[Set("x", "1"), Delete("x")]`, `get` returns `Some("1")`:
`get_scan` matches `Set("x", "1")` at the head and stops.
This represents: key `"x"` was deleted first, then set again.

The ordering of the list encodes the direction of time.

</details>

## Exercises

<div class="exercise" markdown="1">

### Round-trip serialisation (15 minutes)

Implement `to_lines(log: List(Entry)) -> List(String)` and
`from_lines(lines: List(String)) -> List(Entry)`.
Write tests confirming that `log |> to_lines |> from_lines` equals the
original log for a mix of `Set` and `Delete` entries.

</div>

<div class="exercise" markdown="1">

### Indexed get (15 minutes)

Add a function that builds a `Dict(String, String)` index from the log
and uses it for O(1) lookups.
Compare the interface to the scan-based `get`:
both return `Option(String)`, so callers do not need to change.

</div>

<div class="exercise" markdown="1">

### Write-ahead log (20 minutes)

Extend the demo to write each new `Entry` to a text file using `simplifile`.
Add a `load(path: String) -> Result(List(Entry), String)` function
that reads and parses the file on startup.
Write a test that writes a few entries, loads them back, and confirms the result.

</div>
