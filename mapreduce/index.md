# MapReduce

<div class="callout" markdown="1">

-   MapReduce splits data processing into three phases: map, shuffle, and reduce.
-   The map phase applies a user function to each input, producing `(key, value)` pairs.
-   The shuffle phase groups all pairs by key.
-   The reduce phase applies a user function to each key's list of values
     to produce a single result.
-   Generic type parameters let one `mapreduce` function handle many different tasks.

</div>

## The Pattern

-   MapReduce is a programming model for processing large datasets in parallel.
-   Introduced in 2004, it appears in Spark, Hadoop, and many stream processing systems
-   The key insight:
    if the map function produces `(k, v)` pairs
    and the reduce function takes `(k, List(v))`,
    the framework can group and aggregate without knowing anything about the domain

## Types

-   A type alias names the map output:

[%inc src/wordcount_demo.gleam mark=mapresult_type %]

-   `MapResult(k, v)` is just a list of tuples
-   Type aliases do not create new types
    -   `MapResult(String, Int)` and `List(#(String, Int))` are identical to the compiler
    -   The alias just makes function signatures easier to read

## The Framework

-   The `mapreduce` function is the core:

[%inc src/wordcount_demo.gleam mark=mapreduce_fn %]

-   `list.flat_map(inputs, mapper)` calls `mapper` on every input
    and concatenates the resulting lists of pairs
-   `shuffle(pairs)` groups pairs by key into a `Dict(key, List(val))`
-   `dict.map_values(grouped, reducer)` calls `reducer(key, values)` for each key
    and replaces the `List(val)` with a single `val`
-   The `shuffle` helper folds over the pair list,
    appending each value to the list for its key:

[%inc src/wordcount_demo.gleam mark=shuffle_fn %]

## Generic Type Parameters

-   The signature for `mapreduce` uses three type variables:
    -   `elem` is the input element type
    -   `key` is the key type in the output pairs
    -   `val` is the value type
-   When we write `mapreduce(words, fn(w) { [#(w, 1)] }, ...)`,
    Gleam infers `elem = String`, `key = String`, `val = Int`.
-   The types constrain what is possible without restricting which problem is solved

## Word Count

[%inc src/wordcount_demo.gleam mark=word_count_fn %]

-   `Mapper`: each word produces one `(word, 1)` pair
-   `Reducer`: sum all the 1s for a given word

-   For input `["the", "quick", "brown", "the"]` the map phase produces:

```
[#("the", 1), #("quick", 1), #("brown", 1), #("the", 1)]
```

-   After shuffle, this is:

```
{"the": [1, 1], "quick": [1], "brown": [1]}
```

-   After reduce, it becomes:

```
{"the": 2, "quick": 1, "brown": 1}
```

## Extension Count

-   Extension count tallies files by filename extension
    (e.g., how many `.gleam` files vs. `.md` files are in a directory):

[%inc src/wordcount_demo.gleam mark=extension_count_fn %]

-   `Mapper`: splits the filename on `.` and produces `(ext, 1)` if there is exactly one dot;
    produces `[]` (no pairs) otherwise
-   `Reducer`: identical sum
-   Notice that returning `[]` from the mapper is how MapReduce handles
    inputs that should be filtered out

## Testing

[%inc test/mapreduce_test.gleam mark=word_count_test %]

-   `word_count_basic_test` checks counts for a repeated-word input
-   `word_count_empty_test` confirms an empty input produces an empty dict
    (not shown; no marks needed for a one-liner)

[%inc test/mapreduce_test.gleam mark=extension_count_test %]

-   `extension_count_test` confirms that files without a dot produce no entry

## Check Understanding

<details markdown="1">
<summary markdown="1">How does MapReduce scale to multiple machines?</summary>

In a distributed setting,
the map phase runs in parallel on many machines,
each processing a slice of the input.
The shuffle phase transfers pairs across the network
so that all pairs with the same key end up on the same machine.
The reduce phase then runs in parallel,
one machine per key (or per range of keys).

The framework handles the network transfers;
the user only writes the mapper and reducer.
This is why MapReduce scales so well:
adding more machines speeds up the map and reduce phases
without any changes to user code.

</details>

<details markdown="1">
<summary markdown="1">What does a mapper return for an input it wants to exclude,
and what happens to that input during shuffle and reduce?</summary>

It returns `[]` (an empty list).
`list.flat_map` concatenates all mapper outputs,
so an empty return contributes no pairs to the pair list.
The key never appears in the shuffle dict,
and the reducer is never called for it.
Returning `[]` is the idiomatic MapReduce filter.

</details>

## Exercises

<div class="exercise" markdown="1">

### Extension counter (10 minutes)

Use the `mapreduce` framework to find files that are exactly the same size.

</div>

<div class="exercise" markdown="1">

### Combiner step (20 minutes)

A combiner is a reduce step run on the map output before shuffle to reduce data volume.
Add an optional `combiner: fn(b, List(c)) -> c` parameter to `mapreduce`.
If provided,
apply it to each key's values before shuffle.
For word count the combiner is identical to the reducer (sum),
so the only observable effect is performance.
Test that the result is the same with and without the combiner.

</div>

<div class="exercise" markdown="1">

### Inverted index (20 minutes)

An [%g inverted_index "inverted index" %] maps each word to
the list of documents that contain it.
Write `invert(docs: List(#(String, String))) -> dict.Dict(String, List(String))`
where each input tuple is `(document_id, text)`.

</div>

<div class="exercise" markdown="1">

### Prefix scan (20 minutes)

A prefix scan applies a binary operation across a sequence to produce running totals.
For example, summing `[1, 2, 3, 4]` gives `[1, 3, 6, 10]`.
Implement `prefix_scan(inputs: List(Int), combine: fn(Int, Int) -> Int) -> List(Int)`
using `list.index_map` to produce `(index, value)` pairs in the map phase,
then fold in the reduce phase.
Test with both sum and max.

</div>
