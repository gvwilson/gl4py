# Streaming CSV Processing

<div class="callout" markdown="1">

-   Loading an entire CSV file into memory before processing wastes resources
    and fails on files larger than available RAM.
-   A streaming fold processes one row at a time,
    accumulating a result without ever storing the full dataset.
-   When reading in fixed-size chunks, a row may be split across two chunks;
    a carry-forward buffer holds the incomplete tail until the next chunk arrives.
-   The chunk-based fold and the line-based fold produce identical results,
    which makes the simpler version easy to test first.

</div>

## Why Stream?

-   A 4 GB web log file contains roughly 40 million rows
-   Reading it all into memory before computing the total request count
    uses 4 GB of RAM and takes longer to start than computing the answer
-   The fix is to process each row as it arrives and keep only a running total:
    never store what you do not need
-   This lesson builds that pattern in two steps:
    a simple line-by-line fold, then a chunk-based fold that simulates
    reading from a file system one block at a time
-   The same fold function works for both, confirming that the chunk logic
    adds no new bugs

## Parsing One Row

[%inc src/stream_demo.gleam mark=parse_fn %]

-   `string.trim` removes leading and trailing whitespace before the empty check
-   A blank line or a line containing only spaces returns `Error`,
    which the fold will skip
-   A non-empty line is split on commas with `string.split`,
    producing a list of field strings
-   This version does not handle quoted fields that contain commas;
    supporting those would require a state machine similar to the one
    in the [State Machines](@/machine/) lesson

## Folding Over Rows

[%inc src/stream_demo.gleam mark=fold_fn %]

-   `fold_rows` splits the entire text on newlines and folds over the resulting list
-   For each line, `parse_row` either returns `Error` (skip) or `Ok(fields)` (call `f`)
-   `fold_with_header` handles the common case where the first line is a header:
    it pattern-matches on the line list and drops the first element before folding
-   The fold accumulator `b` is completely generic:
    it could be a count, a sum, a list, or any other value the caller chooses

## Chunk-Based Reading

[%inc src/stream_demo.gleam mark=chunk_fn %]

-   `to_chunks` splits the text into pieces of at most `chunk_size` characters,
    simulating the fixed-size reads that a real file system API performs
-   `fold_csv` feeds those chunks to `do_fold_csv` with an empty buffer
-   On each chunk, the buffer from the previous iteration is prepended to form `combined`
-   `string.split(combined, "\n")` separates complete rows from the trailing fragment:
    all lines except the last ended with a newline and are complete;
    the last line is carried forward as the new buffer
-   When all chunks are consumed, the final buffer is flushed as the last row
    (unless it is blank)
-   The two-character constant `chunk_size = 32` makes the buffer behavior
    visible even with short test inputs

## Running the Example

[%inc src/stream_demo.gleam mark=main_example %]

-   `fold_with_header` counts three data rows and sums the scores to 259
-   `fold_csv` counts four rows because it does not skip the header;
    the caller decides whether the first row is a header
-   Changing `chunk_size` to 8 or 4 would produce the same counts,
    confirming that chunk boundaries do not affect the result

## Testing

[%inc test/stream_test.gleam mark=tests %]

-   `parse_row_*` tests cover both success and the two forms of empty input
-   `fold_rows_skips_blank_test` confirms that the blank line between the two
    data rows is silently skipped
-   `fold_csv_same_as_fold_rows_test` is the key correctness check:
    both approaches must agree on the row count for the same input

## Check Understanding

<details markdown="1">
<summary markdown="1">Why does `do_fold_csv` carry the last line of each chunk
forward as the buffer rather than processing it immediately?</summary>

A chunk boundary can fall in the middle of a row.
For example, if chunk 1 ends with `"Ali"` and chunk 2 starts with `"ce,30\n"`,
the row for Alice is split across the two chunks.
`string.split(combined, "\n")` separates complete rows (those followed by `\n`)
from the tail that has no newline yet.
Carrying that tail forward and prepending it to the next chunk
reconstructs the full row before passing it to `parse_row`.
Processing the tail immediately would either drop Alice's row
or produce a partial parse with only `"Ali"` as the first field.

</details>

<details markdown="1">
<summary markdown="1">What does `fold_with_header` produce for a string that contains
only a header line and no data rows?</summary>

`string.split(text, "\n")` produces a one-element list `[header_line]`.
The pattern `[_]` matches — one element — and the function returns `init`
without calling `f` at all.
This is correct: a CSV file with only a header has zero data rows,
so the accumulator should be unchanged.

</details>

## Exercises

<div class="exercise" markdown="1">

### Running average (15 minutes)

Write `running_average(text: String, col_idx: Int) -> Float`
that computes the average of the numeric values in a given column index
across all data rows.
Use `fold_rows` and accumulate a `#(Int, Int)` pair of `(sum, count)`,
then divide at the end.
Return `0.0` for an empty or all-unparseable column.

</div>

<div class="exercise" markdown="1">

### Skip-on-error policy (15 minutes)

Modify `fold_rows` into `fold_rows_strict` that stops and returns `Error(row_number)`
on the first malformed row rather than skipping it.
The row number is 1-indexed.
Write two tests: one where no rows are malformed (should return `Ok(final_acc)`),
and one where the second row is blank (should return `Error(2)`).

</div>

<div class="exercise" markdown="1">

### CSV writer (10 minutes)

Write `write_csv(rows: List(List(String))) -> String`
that joins each inner list on `","` and each row on `"\n"`,
adding a trailing newline.
Write three tests: empty input, one row, multiple rows.
Confirm that `fold_rows(write_csv(rows), 0, fn(acc, _) { acc + 1 }) == list.length(rows)`.

</div>

<div class="exercise" markdown="1">

### Quoted fields (20 minutes)

A quoted CSV field is surrounded by `"..."` and may contain commas.
For example, `Alice,"30,5",engineer` has three fields.
Write `parse_row_quoted(line: String) -> Result(List(String), String)` that handles this.
A minimal approach: split on `","` tokens that are outside any open `"` pair.
Write at least four tests covering fields with and without quotes.

</div>
