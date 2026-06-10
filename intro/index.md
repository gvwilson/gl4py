# Introduction

<div class="syllabus" markdown="1">

-   Gleam is a statically-typed, purely functional language that runs on the
    Erlang VM and can also compile to JavaScript.
-   This tutorial is written for Python programmers who want to understand
    functional programming through practical applications, not theory.

</div>

## Why Gleam?

Every programmer eventually runs into a project where threads behave strangely,
a server falls over at three in the morning,
or refactoring breaks something in a module nobody touched.
Gleam addresses all three problems with two design decisions:
make illegal states impossible to represent,
and run everything on a runtime built for failure.

-   Gleam compiles to [%g erlang "Erlang" %] [%g bytecode "bytecode" %]
    and runs on the [%g beam_vm "BEAM virtual machine" %]
    -   The BEAM was designed in the 1980s for telephone switches
        that had to run without interruption for years at a time
    -   BEAM applications have handled billions of users on small clusters
-   Gleam also compiles to JavaScript
    -   The same source code can target both servers and browsers
    -   The [%g lustre "Lustre" %] package uses this to build browser applications in Gleam
-   Gleam is [%g statically_typed "statically typed" %]
    -   The compiler checks types before the program runs
    -   A function that claims to return an `Int` cannot secretly return `Nil`
    -   Refactoring is faster because the compiler tells you exactly what broke

## Who This Tutorial Is For

This tutorial assumes you are comfortable with Python:
you can write functions,
work with lists and dictionaries,
and read a stack trace.
It does not assume any experience with:

-   Erlang, Elixir, or the BEAM VM
-   Strongly-typed languages like Rust, Haskell, or TypeScript
-   Functional programming concepts like immutability or algebraic data types

If you have written some JavaScript or another scripting language
and can follow Python examples,
you will be fine.
The explanations throughout these lessons compare Gleam's approach to Python equivalents,
so you have a concrete anchor for each new idea.

## The BEAM in Thirty Seconds

-   Up until 2025,
    Python ran code in a single process
    with a [%g gil "Global Interpreter Lock" %] (GIL) that prevented true parallelism
-   BEAM takes the opposite approach
    -   It runs thousands or millions of [%g lightweight_process "lightweight processes" %] concurrently
    -   Each has its own memory
    -   There is no shared state between processes
-   If a process crashes, it cannot corrupt another process's memory
    -   A [%g supervisor "supervisor" %] can restart the failed process
         and keep the rest of the system running
-   Erlang has worked this way since 1986
-   Gleam brings a modern type system to the same runtime

## Setting Up

-   [Erlang/OTP][erlang-download]: the runtime Gleam compiles to
    -   This tutorial was built on v29.0.1
-   [Gleam][gleam-install]: the compiler and build tool
    -   This tutorial was built on v1.16.0
-   Once both are installed, create and run your first project:

```bash
gleam new hello_gleam
cd hello_gleam
gleam run
```

-   You should see `Hello from hello_gleam!`.
-   `gleam new` creates this layout

[%inc hello_gleam.txt %]

-   `gleam run` adds:
    -   `manifest.toml`: requirements and pinned package versions
    -   `build/`: build artefacts (do not commit to version control)

## Lesson Structure

-   A short introduction explaining what the lesson builds and why
-   Code is shown first, then explained with bullet points
-   Self-test questions follow in expandable boxes
-   Exercises are at the end

## A Few Differences Between Gleam and Python Syntax

-   No colons at the end of function or type definitions
-   Blocks use `{` and `}` instead of indentation
-   Comments use `//` instead of `#`
-   String concatenation uses `<>` instead of `+`
-   Floating-point arithmetic uses `+.`, `-.`, `*.`, `/.` to distinguish from integer arithmetic
-   No `return` statement: the last expression in a function is its value
-   Type annotations are optional in most places; the compiler infers them

## Check Understanding

<details markdown="1">
<summary markdown="1">What does "statically typed" mean in practice?</summary>

In a statically typed language,
the type of every expression is known at compile time before the program runs.
The compiler rejects programs where you add an integer to a string,
pass the wrong number of arguments to a function,
or forget to handle an error.
Python determines types at runtime,
so these mistakes surface as exceptions during execution.
Gleam determines types at compile time,
so many mistakes never make it into a running program.
The trade-off is that you *must* think about types explicitly as you are writing code.

</details>

<details markdown="1">
<summary markdown="1">What are the key features of the BEAM runtime?</summary>

The BEAM runs many lightweight processes concurrently on all available CPU cores,
with no shared memory between them.
A crash in one BEAM process cannot corrupt any other process's state.
This isolation is why BEAM-based systems can use supervisors
that restart failed components automatically,
without restarting the entire application.

</details>
