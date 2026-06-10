# Vector Clocks and Eventual Consistency

<div class="syllabus" markdown="1">

-   The CAP theorem says a distributed system subject to network partitions
    must choose between consistency and availability.
-   Vector clocks track causal history:
    each node's counter records how many events that node has seen.
-   Merging two clocks takes the element-wise maximum,
    producing a clock that reflects everything both nodes have seen.
-   One clock dominates another if every counter is at least as large.
-   When neither clock dominates the other,
    the writes are concurrent and a conflict resolution policy is needed.

</div>

## The CAP Theorem

-   When a network partition splits a distributed system
    into two groups that cannot communicate,
    it must make a choice between:
    -   Consistency: every node sees the same data,
        even if that means refusing some requests until connectivity is restored
    -   Availability:
        every node continues to respond,
        even if that means different nodes return different values
-   Most distributed databases choose availability
    and provide [%g eventual_consistency "eventual consistency" %]
    -   Replicas diverge during a partition and converge when they reconnect
-   This lesson models the convergence mechanism: [%g vector_clock "vector clocks" %]

## Vector Clocks

-   A vector clock is a map from node IDs to event counts
-   When node `n` performs an operation, it increments its own counter
-   When two nodes synchronize, they merge their clocks by taking the element-wise maximum
-   The representation is a `Dict(String, Int)`:

[%inc src/clock_demo.gleam mark=merge_fn %]

-   `dict.combine` merges two dicts
    -   For keys present in both, the merge function is applied
    -   Keys present in only one dict pass through unchanged
-   `int.max(va, vb)` keeps the larger counter for each shared key

## Dominance

-   Clock `a` dominates clock `b` if `a` has seen everything `b` has seen and possibly more:

[%inc src/clock_demo.gleam mark=dominates_fn %]

-   For every node in `a`, `a`'s counter must be `>=` `b`'s counter
-   `result.unwrap(dict.get(b, node), 0)` treats a missing counter as zero
    -   If `b` has not recorded any events from that node, `a`'s value is automatically `>=`
-   `dominates(a, b)` means `a` happened after `b` (causally)
-   If both `dominates(a, b)` and `dominates(b, a)` are false, the writes are concurrent

## Simulating Two Replicas

-   Replica A has only seen events from node `n1`:

```
{"n1": 1}
```

-   Replica B has seen more events from `n1` and also events from `n2`:

```
{"n1": 2, "n2": 1}
```

-   `dominates(a, b)` is false: `a`'s `n1` counter (1) is less than `b`'s (2)
-   After merging, the combined clock is:

```
{"n1": 2, "n2": 1}
```

-   The merged clock dominates both originals
-   This is the mathematical property that guarantees eventual convergence
    -   Any two replicas that exchange clocks and merge will reach the same state

## Versioned Values

-   To track which version of a value is current, pair the value with its clock:

[%inc src/clock_demo.gleam mark=versioned_type %]

[%inc src/clock_demo.gleam mark=resolve_fn %]

-   `Versioned(v)` is a generic type: any `v` can be versioned
-   `resolve` picks the newer value when one clock dominates the other
-   For concurrent writes, it falls back to a deterministic tie-break
    -   Here: `string.compare` picks the lexicographically smaller value
-   The merged clock always advances: no information is lost

## Testing

[%inc test/eventual_test.gleam mark=tests %]

-   `merge_takes_max_test` checks that the merged clock holds the maximum counter per node
-   `dominates_true_test` and `dominates_false_test` cover both directions of the relation
-   `concurrent_test` confirms that neither clock dominates when counters have crossed
-   `merged_dominates_both_test` verifies the convergence guarantee

## Check Understanding

<details markdown="1">
<summary markdown="1">What is a grow-only counter (G-counter)?</summary>

A G-counter is the simplest CRDT (conflict-free replicated data type).
Each node maintains a count of how many times it has incremented.
The global count is the sum of all nodes' counts.
To merge two G-counters, take the element-wise maximum (the same as `merge_clocks`).
The result is always `>=` either input, so merges can never decrease the count.
This is exactly what vector clocks represent: a G-counter per node ID.

</details>

<details markdown="1">
<summary markdown="1">Node `n1` has clocks `{"n1": 2, "n2": 1}` and `{"n1": 1, "n2": 3}`.
Does either clock dominate the other, and what does the merged clock look like?</summary>

Neither dominates the other.
For the first clock to dominate the second, every counter must be `>=`.
The `n1` counter satisfies that (2 >= 1), but the `n2` counter does not (1 < 3).
These are concurrent writes.

The merged clock is `{"n1": 2, "n2": 3}`: element-wise maximum.
The merged clock dominates both originals.

</details>

## Exercises

<div class="exercise" markdown="1">

### G-counter (15 minutes)

Implement a grow-only counter as a type alias for `Dict(String, Int)`.
Write `increment(counter, node_id)` that adds 1 to the given node's
count, `merge_counters(a, b)` using `merge_clocks`, and
`total(counter)` that returns the sum of all counts.
Simulate two replicas each incrementing independently; merge and assert
the total is the sum of both.

</div>

<div class="exercise" markdown="1">

### Versioned store (20 minutes)

Implement `type Versioned(v) { Versioned(value: v, clock: Dict(String, Int)) }`.
Write `resolve(local: Versioned(a), remote: Versioned(a)) -> Versioned(a)`
that returns the dominant version or, for concurrent writes, the
version with the lexicographically smaller value.
Write three tests: local dominates, remote dominates, concurrent.

</div>

<div class="exercise" markdown="1">

### Increment clock (10 minutes)

Write `increment(clock: Dict(String, Int), node: String) -> Dict(String, Int)`
that bumps the counter for `node` by 1.
Add tests confirming that incrementing a node not yet in the clock
starts it at 1 and that incrementing an existing node adds 1 to its
current value.

</div>

<div class="exercise" markdown="1">

### Concurrent write count (10 minutes)

Write `count_concurrent(versions: List(Versioned(String))) -> Int` that
counts how many pairs of versions in the list are concurrent (neither
dominates the other).
Test with a list where all versions are from the same causal history
(count = 0) and one where all are concurrent (count = n*(n-1)/2).

</div>
