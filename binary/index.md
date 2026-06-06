# Binary Data Packer

<div class="callout" markdown="1">

-   `BitArray` represents sequences of bits and bytes
-   `<<n:32-big, rest:bits>>` in a pattern destructures a `BitArray`
    into a 32-bit big-endian integer and the remaining bytes
-   A format descriptor type (`Fmt`) mirrors the value type (`Value`)
    but carries no data, separating schema from content
-   Encoding and decoding recurse over paired lists of formats and values
-   `Result(List(Value), String)` propagates decode errors cleanly

</div>

## The Value and Format Types

-   Text representations like JSON are easy to read but wasteful
    -   The integer `1000000` takes seven bytes as ASCII
        but only four bytes as a 32-bit integer
    -   And good luck representing a movie as characters
-   Two types work together:

[%inc src/pack_demo.gleam mark=value_types %]

-   `Value` represents a single value that can be packed:
    either an integer or a string
-   `Fmt` is the [%g schema "schema" %] descriptor:
    it says what kind of value to expect at each position
-   `FInt` and `FStr` carry no payload: they are pure tags
-   Keeping them separate means
    the same format list can pack different value lists without mixing concerns
-   The closest equivalent in Python is the `struct` format string `">I7s"`
    -   But that is an untyped string with no compiler help
    -   Here the types enforce that every `FInt` in the format list
        lines up with a `VInt` in the value list

## Packing Values

-   `pack` encodes a list of values guided by a format list:

[%inc src/pack_demo.gleam mark=pack_fn %]

-   `<<>>` is an empty `BitArray`
-   `<<n:32-big, pack(frest, vrest):bits>>` concatenates
    a 32-bit [%g big_endian "big-endian" %] integer with the recursive result
    -   `:bits` splices a `BitArray` into a larger one
-   For strings, `string_to_bytes` converts the `String` to UTF-8 bytes
    -   `bit_array.byte_size` measures it
    -   Then the length is written as a 32-bit prefix before the bytes
-   The final `_, _ -> <<>>` handles mismatched lists
    -   In production code this would return a `Result`
-   The `BitArray` literal syntax mirrors pattern-matching syntax
-   The same annotations (`32-big`, `utf8`, `bits`) appear on both sides
-   This symmetry makes encoding and decoding code look parallel

## Unpacking Values

-   Decoding reverses the process by consuming bytes
     guided by the same format list:

[%inc src/pack_demo.gleam mark=unpack_fn %]

-   `<<n:32-big, rest:bits>>` binds the first four bytes as an integer
    and `rest` as the remaining bytes
-   `<<len:32-big, str_data:bytes-size(len), rest:bits>>` reads the length prefix,
    then reads exactly `len` bytes into `str_data`
-   `bit_array.to_string(str_data)` converts those bytes back to a `String`
    and returns `Ok(s)` or `Error(Nil)` if the bytes are not valid UTF-8
-   Values are accumulated in reverse and reversed at the end
-   `Error("unexpected end of data")` fires when the pattern match fails,
    meaning the `BitArray` ran out of bytes before the format list did
-   The `bytes-size(len)` annotation is the key to variable-length fields
    -   It reads exactly `len` bytes, where `len` was bound by the preceding `len:32-big`

## Handling Corrupt Data

-   Decoding real-world data requires dealing with truncation and corruption

[%inc src/unpack_demo.gleam mark=corrupt_demo %]

-   `<<packed:bits, 255>>` appends an extra byte to simulate
     a corrupted or over-long message
-   `unpack` is called with the same format list and the corrupted data
-   Because the format list is exhausted first (all values decoded),
    the extra byte is silently ignored
    -   `Ok(list.reverse(acc))` fires when the format list is empty,
        regardless of remaining bytes
-   To reject trailing bytes, change the base case to
    `[], <<>> -> Ok(list.reverse(acc))` and
    `[], _ -> Error("trailing bytes")`
-   The debug output shows that the round-trip succeeds
    -   I.e., the extra byte does not corrupt the result

## BitArray Literal Syntax Reference

These annotations appear identically in construction (`<<n:32-big>>`)
and in pattern matching (`<<n:32-big, rest:bits>>`).

| Annotation | Meaning |
|------------|---------|
| `n:8` | 8-bit unsigned integer |
| `n:16-big` | 16-bit big-endian integer |
| `n:32-big` | 32-bit big-endian integer |
| `n:64-big` | 64-bit big-endian integer |
| `s:utf8` | UTF-8 encoded string |
| `data:bytes` | a `BitArray` as raw bytes |
| `data:bits` | a `BitArray` as raw bits |
| `data:bytes-size(len)` | exactly `len` bytes (len must be bound earlier) |

<div class="callout" markdown="1">

Python's `struct.pack(">I", 42)` and `struct.unpack(">I", data)` do the same job
 but the format string is parsed at runtime.
A typo in `">II"` (two integers) is a runtime error, not a compile error.

Gleam checks the `BitArray` annotations at compile time.
The format descriptor list (`List(Fmt)`) is also statically typed:
`[FInt, FStr, FInt]` will only accept `[VInt(...), VStr(...), VInt(...)]`.
A mismatched list falls through to the `_, _ -> <<>>` fallback,
which could be made into a `Result` error.

The tradeoff is that Python's `struct` handles dozens of format characters
(floats, signed integers, padding) out of the box.
Gleam's `BitArray` handles arbitrary bit widths and endianness natively,
but floating-point packing requires either bit manipulation or an extra library.

</div>

## Testing

[%inc test/binary_test.gleam mark=examples %]

-   Each test packs a value and immediately unpacks it,
    checking that the decoded list equals the original
-   `truncated_data_test` passes only one byte for an integer field
    -   The pattern `<<n:32-big, rest:bits>>` cannot match,
        so `Error("unexpected end of data")` is returned

## Check Understanding

<details markdown="1">
<summary markdown="1">What is big-endian and why does it matter?</summary>

Big-endian stores the most significant byte first.
The number 1 as a 32-bit big-endian integer is `00 00 00 01`.
Little-endian (used by x86 processors) reverses this: `01 00 00 00`.
Network protocols  like TCP/IP use big-endian,
sometimes called "network byte order".
When two systems with different native endianness communicate,
using an explicit annotation (`32-big` or `32-little`)
ensures both sides agree on the byte order.

</details>

## Exercises

<div class="exercise" markdown="1">

### Name and age record (15 minutes)

Pack a record containing a name (`String`) and an age (`Int`).
Unpack it and confirm with `assert`.
Then intentionally truncate the packed bytes to one fewer byte
and confirm `unpack` returns an `Error`.

</div>

<div class="exercise" markdown="1">

### Reject trailing bytes (10 minutes)

Modify `unpack_loop` so that leftover bytes after all format fields have been consumed
produce `Error("trailing bytes")`.
Add a test that packs `[VInt(1)]` and then appends an extra byte,
confirming the error is returned.

</div>

<div class="exercise" markdown="1">

### Add a float type (20 minutes)

Add `VFloat(Float)` to `Value` and `FFloat` to `Fmt`.
Gleam floats are 64-bit IEEE 754.
The annotation for a 64-bit float in a `BitArray` is `f:float`.
Update `pack` and `unpack_loop` to handle the new variant and write two tests.

</div>

<div class="exercise" markdown="1">

### Nested record (20 minutes)

Design a format that packs a list of records,
where the list itself is length-prefixed.
Add `FList(List(Fmt))` to `Fmt` and handle it in `pack` and `unpack_loop`.
A packed list starts with a 32-bit count
followed by that many repetitions of the inner format.

</div>
