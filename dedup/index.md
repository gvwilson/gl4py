# File Deduplicator

<div class="syllabus" markdown="1">

-   Files with identical content have identical cryptographic hashes.
-   `gleam/dict` provides an efficient key-value store.
-   `dict.get` returns a `Result` to force explicit handling of the missing-key case.
-   Extending a data representation is straightforward when the types are explicit.

</div>

## The Problem

-   Disk space fills up with copies of the same file scattered across directories
-   A file deduplicator scans a set of paths,
    groups them by content,
    and reports which groups contain more than one copy
-   Standard approach is to [%g hash "hash" %] each file's contents
    -   Two files with the same hash almost certainly have the same bytes
-   In production, a cryptographic hash like SHA-256 is computed from the file's bytes;
    in this example, `hash_content` returns the content string directly
    to keep the code self-contained

## Grouping Files by Hash

-   A `Dict(String, List(String))` maps each hash to the list of file paths that share it
-   Build this dictionary one file at a time:

[%inc src/group_demo.gleam mark=group_fn %]

-   `list.fold` iterates over `files`, threading the accumulator `acc` through each step
-   Each file is a `#(path, content)` pair; `hash_content(content)` produces the lookup key
-   `dict.get(acc, hash)` returns `Ok(existing_list)` if the hash is already present
     or `Error(Nil)` if it is not
-   `result.unwrap([])` is used via `|>` to provide an empty list as the default
    -   `dict.get` returns `Result(v, Nil)`, so `result.unwrap` extracts the value or returns the default
-   `dict.insert(acc, hash, [path, ..existing])` prepends the new path
    and stores the updated list
-   Each call to `list.fold` produces a new dictionary
    -   Gleam data structures are immutable, so the original `acc` is never mutated

## Finding Duplicates

Once the files are grouped, finding duplicates is a filter:

[%inc src/group_demo.gleam mark=find_fn %]

-   `group_by_hash` returns the dict of all groups
-   `dict.values` extracts just the lists (dropping the hash keys)
-   `list.filter` keeps only groups where `list.length(paths) > 1`
-   To limit the result to the top ten groups by size, add `|> list.take(10)` at the end

## Reporting

-   Convert the structural result into a human-readable string:

[%inc src/group_demo.gleam mark=report_fn %]

-   The empty-list case is explicit
    -   Returning a special string is clearer than returning `""`
     and letting the caller decide what it means

## Tracking File Size

-   Knowing that duplicates exist is useful
-   Knowing how much space they waste is more useful
-   Add a `size` field to the record type to capture this:

[%inc src/size_demo.gleam mark=fileinfo %]

-   The extended function returns both the duplicate groups and the total wasted bytes:

[%inc src/size_demo.gleam mark=size_fn %]

-   The grouped dict now stores `#(paths, size)` tuples instead of plain lists
-   The `dup_groups` filter still checks `list.length(paths) > 1`
-   `savings` folds over the duplicate groups:
     for each group with `n` copies, `(n - 1) * size` bytes are redundant
-   The return type `#(List(List(String)), Int)` is a tuple
    -   A named record type would be clearer for a function with more fields to return

## Walking the Filesystem

-   The demos above use hand-crafted lists; a real deduplicator reads actual files
-   Two additions are needed: reading command-line arguments and walking a directory tree
-   The `argv` package provides `argv.load().arguments`, a `List(String)` of the arguments
    passed after `--` when running `gleam run -- /path/to/dir`:

[%inc src/walk_demo.gleam mark=args_fn %]

-   `simplifile.read_directory` lists the names (not full paths) of entries in one directory
-   `filepath.join` builds the full path; `simplifile.file_info` returns metadata including `size`
-   `simplifile.file_info_type` distinguishes regular files from directories and other entries:

[%inc src/walk_demo.gleam mark=walk_fn %]

-   `list.flat_map` is used instead of `list.map` because each entry may expand to zero or more results
    -   An unreadable entry returns `[]`, a file returns a one-element list, and a directory recurses
-   Reading the file content and using it as a hash key is only practical for small files;
    in production, replace `hash_file` with a call to a crypto library:

[%inc src/walk_demo.gleam mark=hash_fn %]

-   The `run` function ties everything together: walk, hash, group, and report:

[%inc src/walk_demo.gleam mark=run_fn %]

## Testing

[%inc test/dedup_test.gleam mark=examples %]

-   `no_duplicates_test` confirms the base case
-   `one_group_test` checks that two files with the same hash form one group
-   `three_copies_test` digs into the group to verify it contains three paths
-   Tests do not care about ordering within a group
    -   If ordering matters (e.g., for deterministic output),
         use `list.sort(result, string.compare)` before asserting

## Check Understanding

<details markdown="1">
<summary markdown="1">Why does `dict.get` return `Result` instead of a default value?</summary>

`dict.get` could return `Nil` or an empty list when a key is missing,
but that would silently hide bugs:
a function that returns `[]` when the key is absent
looks exactly like a function that found an empty list.
Returning `Result(List(String), Nil)` forces the caller to decide what to do.
In this code the right default is `[]`,
so `|> result.unwrap([])` makes that choice explicit rather than hiding it.

</details>

<details markdown="1">
<summary markdown="1">Why does `group_by_hash` prepend the new path with `[path, ..existing]`
instead of appending it with `list.append(existing, [path])`?</summary>

Prepending with `[path, ..existing]` is O(1) in Gleam because lists are linked lists:
it creates a new node pointing to the existing list without copying it.
Appending with `list.append` is O(n) because it must traverse the entire existing list
to attach the new element at the end.
Since the order of paths within a duplicate group does not affect correctness,
prepending is the right choice here.

</details>

## Exercises

<div class="exercise" markdown="1">

### Most-duplicated file (10 minutes)

Given the result of `find_duplicates`,
write a function `most_duplicated` that returns the group with the most copies.
Its return type should be `Result(List(String), Nil)`:
`Ok(group)` when at least one duplicate group exists,
and `Error(Nil)` when there are no duplicates.
Write two tests:
one for an empty input and one for a list with multiple groups of different sizes.

</div>

<div class="exercise" markdown="1">

### Size savings (15 minutes)

The `find_duplicates_with_size` function shows how to track wasted space alongside duplicate groups.
If a file with hash H appears n times and each copy is s bytes,
then n - 1 of those copies are redundant, wasting (n - 1) * s bytes.

Using `FileInfo` (path, hash, size),
write `find_duplicates_with_size` and return `#(List(List(String)), Int)` as shown in the size demo.
Write tests confirming the savings calculation is correct for two groups of different sizes.

</div>

<div class="exercise" markdown="1">

### Skip unreadable files (10 minutes)

Change the input to `List(#(String, Result(String, String)))`
 where the `Result` represents either a valid hash or a read error.
Filter out `Error` entries before grouping.
Write a test confirming that a file with an `Error` hash is excluded from the results.

</div>

<div class="exercise" markdown="1">

### First-block optimisation (20 minutes)

Real deduplicators avoid hashing large files in full when a quick check can rule out duplicates.
The trick is to hash only the first block (e.g., the first 4 KB) of each file to get a `prefix_hash`,
then compute the `full_hash` only for files that share a `prefix_hash`.
Files that differ in their first block cannot be identical,
so skipping their full hash saves time.

Simulate this by giving each file two hashes in a record:
`prefix_hash` (hash of a short prefix) and `full_hash` (hash of the entire content).
Group by `prefix_hash` first; only form full-hash groups for files
whose `prefix_hash` groups have size > 1.
Return only true duplicates (i.e., files that share the same `full_hash`).

</div>
