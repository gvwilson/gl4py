# Glossary

## A

<span id="actor">actor</span>
:   A lightweight, isolated unit of computation that encapsulates
    state and behavior, communicating with other actors solely through
    message passing.

## B

<span id="base_case">base case</span>
:   The branch of a recursive function that returns a result directly
    without making another recursive call, stopping the recursion.

<span id="beam_vm">BEAM virtual machine</span>
:   The Erlang runtime environment, originally designed for telephone
    switches, that runs millions of lightweight processes with no
    shared memory and built-in fault isolation.

<span id="big_endian">big endian</span>
:   A byte ordering convention in which the most significant byte of a
    multi-byte value is stored at the lowest memory address.

<span id="bytecode">bytecode</span>
:   A compact, platform-independent representation of a program that a
    virtual machine interprets rather than executing directly as
    native machine code.

## C

<span id="circular_import">circular import</span>
:   A situation in which module A imports module B and module B
    imports module A (directly or transitively).

<span id="compaction">compaction</span>
:   The process of replacing a full append-only log with a minimal
    equivalent log that contains at most one entry per live key and
    no tombstone entries for deleted keys.

<span id="custom_type">custom type</span>
:   A user-defined type that packages one or more named variants into
    a single type, allowing the compiler to verify that every variant
    is handled in case expressions.

## D

<span id="database_migration">database migration</span>
:   A SQL script that modifies the database schema in a versioned,
    reproducible way.
    Migrations are applied in order at startup so the schema is always
    consistent with the application code.

<span id="dataframe">dataframe</span>
:   A table of named, typed columns that all share the same number of rows,
    used as the primary data structure in data analysis libraries such as
    pandas and Polars.
    Column-oriented storage makes operations on a single column fast.

<span id="depth_first_backtracking">depth-first backtracking</span>
:   A search strategy that explores one path as deeply as possible,
    then backs up to try alternatives when it fails.

<span id="destructuring">destructuring</span>
:   A syntax that unpacks a tuple or record into individual named
    bindings in a single expression.

<span id="dispatch">dispatch</span>
:   The selection of a specific code path based on the structure or
    value of arguments, typically via pattern matching on a tuple of
    inputs.

<span id="dsl">domain-specific language</span> (DSL)
:   A small, specialized language or API designed for one class of tasks.
    Gleam's `gleam/dynamic/decode` provides a DSL for decoding untyped data
    into typed Gleam values.

## E

<span id="erlang">Erlang</span>
:   A programming language and runtime created in the 1980s at
    Ericsson for building fault-tolerant, distributed, real-time
    systems.

<span id="event_log">event log</span>
:   A sequence of immutable records describing every change made to a
    system, where new events are appended rather than existing records
    updated in place.

<span id="eventual_consistency">eventual consistency</span>
:   A replication model in which replicas are allowed to diverge during
    a network partition but guaranteed to converge to the same state
    once all nodes can communicate again.

## F

<span id="fetch_decode_execute">fetch-decode-execute cycle</span>
:   The fundamental loop of a CPU or virtual machine: fetch the next
    instruction from memory, decode its fields to determine the
    operation and operands, execute the operation, and repeat.

<span id="finite_state_machine">finite state machine</span>
:   A computational model consisting of a fixed set of states,
    a set of events, and a transition function that maps each
    (state, event) pair to either a new state or an error.
    State machines enforce which sequences of events are legal,
    making implicit behavior explicit and testable.

## G

<span id="generator">generator</span>
:   In property-based testing, a function that takes a seed and returns
    a randomly generated value of a given type paired with a new seed,
    allowing reproducible sequences of test inputs.

<span id="glob">glob</span>
:   A shell-style pattern that uses wildcards such as `*` (any
    sequence of characters) and `?` (any single character) to match
    filenames or strings.

<span id="gil">Global Interpreter Lock</span> (GIL)
:   A mutex in CPython that prevents more than one thread from
    executing Python bytecode at a time, limiting true parallelism on
    multi-core hardware.

<span id="grapheme">grapheme</span>
:   A user-perceived character in text which may be composed of
    multiple Unicode code points.

<span id="guarded_arm">guarded arm</span>
:   A branch in a `case` expression that includes an `if` condition
    after the pattern, so the arm only matches when both the pattern
    and the condition are true.

## H

<span id="hash">hash</span>
:   A fixed-size value computed from data by a hash function, used to
    map keys to positions in a hash table for fast lookup.

<span id="http_404">HTTP 404</span>
:   The HTTP status code returned when the server cannot find the requested
    resource, indicating that the URL does not exist on that server.

<span id="http_405">HTTP 405</span>
:   The HTTP status code returned when the server understands the request URL
    but does not support the HTTP method used (for example, `DELETE` on a
    read-only endpoint).

## I

<span id="idempotent">idempotent</span>
:   A property of an operation such that applying it multiple times produces
    the same result as applying it once.
    Idempotent database migrations (using `IF NOT EXISTS`) are safe to run
    against an existing database.

<span id="immutable">immutable</span>
:   A property of a binding in which the value assigned to a name
    cannot be changed after it is created.

<span id="inverted_index">inverted index</span>
:   A data structure that maps each term to the list of documents (or
    locations) that contain it, enabling fast full-text search.

## L

<span id="lightweight_process">lightweight process</span>
:   A unit of concurrent execution managed by the BEAM runtime that
    has its own isolated memory and message mailbox, but is far
    cheaper to create and schedule than an operating-system thread.

<span id="lcg">linear congruential generator</span> (LCG)
:   A simple pseudo-random number generator that produces the next value by
    multiplying the current seed by a constant, adding an offset, and taking
    the result modulo a large prime or power of two.

<span id="lustre">Lustre</span>
:   A Gleam package for building browser user interfaces.

## M

<span id="mount">mount</span>
:   To attach a Lustre application to a DOM element so that the runtime
    controls that portion of the page, replacing its contents with the
    rendered virtual DOM tree.

## N

<span id="named_variant">named variant</span>
:   One of the labeled constructors that make up a custom type,
    optionally carrying typed fields.

## O

<span id="opaque_type">opaque type</span>
:   One whose representation is hidden from other modules, so they can
    only interact with it through the functions the module provides.

<span id="opcode">opcode</span>
:   The numeric code that identifies which instruction to execute in a
    machine instruction word; the remaining bits hold operands.

<span id="option_type">Option type</span>
:   A built-in Gleam type with two variants used to represent optional
    values without null pointers.

<span id="otp">OTP</span> (Open Telecom Platform)
:   A set of libraries and design principles for building fault-tolerant
    Erlang and Gleam applications, including actors, supervisors, and the
    `gen_server` behaviour.

## P

<span id="panic">panic</span>
:   An unrecoverable runtime error that immediately terminates the
    current process.

<span id="partial_application">partial application</span>
:   Creating a new function by fixing some of the arguments of an
    existing function, leaving the remaining arguments to be supplied
    later.

<span id="prepend">prepend</span>
:   To add an element to the front of a list, producing a new list
    with that element as the head.

<span id="property_based_testing">property-based testing</span>
:   A testing approach in which a framework generates many random inputs
    and checks that a universal statement (a property) holds for each one,
    rather than checking specific hand-written examples.

## R

<span id="result_type">Result type</span>
:   A built-in Gleam type used to represent computations that may
    fail, forcing callers to handle both success and failure cases at
    compile time.

## S

<span id="schema">schema</span>
:   A formal description of the structure and types of data in a
    record or message.

<span id="shadowed_entry">shadowed entry</span>
:   A log entry that is superseded by a more recent entry for the same
    key, making the earlier entry irrelevant and eligible for removal
    during compaction.

<span id="short_circuit">short-circuit</span>
:   An evaluation strategy that stops as soon as a definite outcome is
    known, skipping remaining steps.

<span id="shrinking">shrinking</span>
:   A step in property-based testing where a framework automatically
    simplifies a failing input to the smallest version that still causes
    the property to fail, making the counterexample easier to diagnose.

<span id="sql_injection">SQL injection</span>
:   A security vulnerability in which an attacker inserts SQL code into a
    query by including it in user input that is interpolated directly into a
    SQL string rather than passed as a parameterised value.

<span id="statically_typed">statically typed</span>
:   A property of a programming language in which the type of every
    expression is checked at compile time rather than discovered at
    runtime.

<span id="supervisor">supervisor</span>
:   A process whose job is to monitor child processes and restart them
    according to a defined strategy when they crash.

<span id="syntactic_sugar">syntactic sugar</span>
:   A shorthand syntax that makes code easier to read or write that
    can always be rewritten in a more verbose but equivalent form.

## T

<span id="tail_recursion">tail recursion</span>
:   A form of recursion in which the recursive call is the last
    operation in the function, allowing the runtime to reuse the
    current stack frame instead of growing the call stack.

<span id="tcp">TCP</span> (Transmission Control Protocol)
:   A network protocol that provides reliable, ordered, connection-oriented
    byte streams between two processes.
    HTTP, database connections, and most application-layer protocols run on top of TCP.

<span id="tuple">tuple</span>
:   A fixed-length, ordered collection of values that may have
    different types, written with a `#` prefix in Gleam.

<span id="type_parameter">type parameter</span>
:   A placeholder in a type definition that stands for any concrete
    type, allowing functions and data structures to work generically
    across element types.

## V

<span id="vector_clock">vector clock</span>
:   A map from node identifiers to event counts used to track causal
    ordering in a distributed system; merging two vector clocks takes
    the element-wise maximum of each node's counter.

<span id="virtual_dom">virtual DOM</span>
:   A tree of plain data values that describes the desired state of a user
    interface.
    The Lustre runtime compares successive trees and applies the minimum
    number of changes to the real browser DOM.
