# Dataframes in Gleam

<div class="callout" markdown="1">

-   A dataframe is a table of named, typed columns
    that all share the same number of rows.
-   Column-oriented storage makes operations on a single column fast,
    while row-oriented access requires zipping all columns together.
-   A custom type with variants for each supported element type
    (`IntCol`, `StrCol`) lets the compiler enforce type safety at access time.
-   `make` validates that all columns have the same length at construction time,
    so downstream functions can assume a consistent shape.
-   Row filtering uses a Boolean mask derived from one column
    applied uniformly to every column in the dataframe.

</div>

## What Is a Dataframe?

-   A [%g dataframe "dataframe" %] is the core abstraction in [pandas][pandas], [Polars][polars], and [R][r]:
    a rectangular table where every column has a name and a uniform type
-   Python programmers reach for `pandas.DataFrame`;
    this lesson builds a minimal version in Gleam to show how dataframes work
-   The key design choices:
    -   Store columns, not rows:
        a `Dict(String, Column)` where each column holds all its values in a list
    -   Record the row count once in the dataframe record,
        rather than recomputing `list.length` on every operation
    -   Validate shape at construction time so all other functions can trust it

## Column Types

[%inc src/dataframe_demo.gleam mark=column_type %]

-   `IntCol(List(Int))` and `StrCol(List(String))` are the two supported types
-   Adding a `FloatCol` or `BoolCol` variant later means adding one case to every
    function that pattern-matches on `Column`
-   The compiler will flag every `case` that fails to handle the new variant,
    turning a potential runtime bug into a compile error

## Building a Dataframe

[%inc src/dataframe_demo.gleam mark=dataframe_type %]

[%inc src/dataframe_demo.gleam mark=make_fn %]

-   `make` takes a list of `(name, column)` pairs and returns a `Result`
-   The first pair establishes the expected row count `n`
-   `list.find` checks whether any column has the wrong length:
    `Ok(#(name, _))` means a bad column was found; `Error(_)` means all are fine
-   `dict.from_list` converts the validated pairs into the column dictionary
-   Returning `Result` here means callers must handle the bad-shape case
    rather than discovering it later as a silent bug

## Accessing Columns

[%inc src/dataframe_demo.gleam mark=accessor_fns %]

-   `int_col` returns `Error` for two distinct reasons:
    the column does not exist, or it exists but holds strings
    -   More generally, something other than integers
-   Pattern matching on `StrCol(_)` before `IntCol(xs)` catches the type mismatch
-   `nrows` and `ncols` are O(1):
    row count is stored directly, and `dict.size` is a constant-time operation

## Selecting a Subset of Columns

[%inc src/dataframe_demo.gleam mark=select_fn %]

-   `select` folds over the requested names and builds a new pair list,
    short-circuiting on the first missing name
-   The accumulator starts as `Ok([])` and stays `Error(msg)` once one name fails
-   `list.reverse` is needed because the fold prepends to the accumulator,
    reversing the order of the names
-   The resulting dataframe keeps the same `nrows` as the original

## Aggregation and Filtering

[%inc src/dataframe_demo.gleam mark=col_sum_fn %]

[%inc src/dataframe_demo.gleam mark=filter_fn %]

-   `col_sum` uses `result.map` to apply `list.fold` inside the `Ok` branch
    without unwrapping manually
-   `filter_rows` builds a Boolean mask by applying the predicate to the named column,
    then passes that mask to every column through `keep_by_mask`
-   `keep_where` zips values with the mask and keeps only the `True` entries,
    using `list.reverse` to restore the original order
-   Every column is filtered by the same mask, so rows stay aligned
-   This is the same pattern as the shuffle phase of [MapReduce](@/mapreduce/):
    group by a key (the mask value), keep only one group

## Running the Example

[%inc src/dataframe_demo.gleam mark=main_example %]

-   The output shows that `age >= 30` keeps Alice and Carol but not Bob
-   `str_col` confirms that the name column was filtered by the same mask as `age`
-   The final `make` call returns `Error` for mismatched column lengths

-   To filter rows on a string column, write a similar function
    that calls `str_col` instead of `int_col`:
    `filter_rows` requires an integer column for the Boolean mask,
    so a separate function is needed for string-column filtering
-   Dataframe operations can be chained with `|>` and `result.try`
    inside a `use` block because each function takes the dataframe
    as its first argument

## Testing

[%inc test/dataframe_test.gleam mark=tests %]

-   `make_valid_test` and `make_length_mismatch_test` cover the two construction paths
-   `filter_rows_test` checks both the row count and the string column values,
    catching bugs where the mask is applied to only one column

## Check Understanding

<details markdown="1">
<summary markdown="1">Why does `make` store `nrows` in the `Dataframe` record
rather than computing it from a column each time it is needed?</summary>

Accessing the length of a list is O(n) in Gleam because lists are singly-linked:
every call to `list.length` walks the whole list.
Storing the row count once avoids this cost for every subsequent `nrows` call
and for operations like `filter_rows` that need the count
after building the new column dictionary.
The trade-off is that `nrows` must be updated correctly in every function
that changes the shape of the dataframe.

</details>

<details markdown="1">
<summary markdown="1">What happens if you call `filter_rows` with a column name that holds strings?</summary>

`filter_rows` calls `int_col(df, name)` first.
`int_col` pattern-matches on the column variant:
if the named column is `StrCol(_)`, it returns `Error("column '...' is not integer")`.
`filter_rows` uses `result.try`, so it propagates that error immediately
without ever applying the predicate or building a mask.
The caller gets an `Error` and no filtering is performed.

</details>

## Exercises

<div class="exercise" markdown="1">

### Float column (15 minutes)

Add `FloatCol(List(Float))` to the `Column` type.
Add `float_col(df, name) -> Result(List(Float), String)`
and `col_mean(df, name) -> Result(Float, String)` that computes the column mean.
Update `make`, `keep_by_mask`, and any other functions that pattern-match on `Column`.
Write at least three tests.

</div>

<div class="exercise" markdown="1">

### Group by (20 minutes)

Write `group_by(df: Dataframe, name: String) -> Result(Dict(String, Dataframe), String)`
that partitions rows by the distinct string values in the named column.
Each key in the result is one distinct string value;
the associated dataframe contains only the rows where that column has that value.
Use `filter_rows` internally.
Test with at least two distinct groups.

</div>

<div class="exercise" markdown="1">

### Add column (10 minutes)

Write `add_col(df: Dataframe, name: String, col: Column) -> Result(Dataframe, String)`
that returns a new dataframe with the given column appended.
Return `Error` if the column length does not match `nrows(df)`
or if a column with that name already exists.
Write three tests: one success, one length mismatch, one duplicate name.

</div>

<div class="exercise" markdown="1">

### Row at index (15 minutes)

Write `row(df: Dataframe, idx: Int) -> Result(Dict(String, String), String)`
that returns all column values for a given row index as a dict mapping column name
to its string representation (use `int.to_string` for integer columns).
Return `Error` if `idx` is negative or out of range.
Test with a valid index, a negative index, and an index equal to `nrows`.

</div>
