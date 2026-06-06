# Virtual Machine

<div class="callout" markdown="1">

-   A simple computer can be modelled as a record holding an instruction pointer,
     a register file, and a block of memory.
-   Each instruction is a custom type variant.
-   An assembler encodes variants into integers and an executor decodes and runs them.
-   The [%g fetch_decode_execute "fetch-decode-execute cycle" %] is
     a tail-recursive function over an immutable `Machine` record.
-   Separating the assembler (pure encoding) from the executor (pure simulation)
     makes each part independently testable.

</div>

## Why Build a VM?

-   A virtual machine is a program that runs other programs
-   Understanding one reveals how real CPUs work:
    fetch an instruction, decode its parts, execute the operation, repeat
-   This lesson builds a minimal VM with four registers,
    a flat integer memory, and five instructions
-   The VM connects several ideas covered earlier:
    -   Custom types and pattern matching (the instruction type)
    -   Recursion over immutable data (the execute loop)
    -   Bit manipulation (packing operands into integers)
    -   Separating pure logic from side effects (no IO inside `execute`)

## Types

-   Two types capture the machine state and the instruction set:

[%inc src/vm_demo.gleam mark=op_machine_type %]

-   `Op` lists every instruction; each variant carries its operands
    -   `Load(reg, val)` puts a literal value into a register
    -   `Add(dst, a, b)` stores `regs[a] + regs[b]` into `regs[dst]`
    -   `Jump(addr)` sets the instruction pointer to `addr`
    -   `JumpIfZero(reg, addr)` jumps only if `regs[reg] == 0`
    -   `Halt` stops the machine
-   `Machine` holds the full CPU state:
    -   `ip` is the instruction pointer (index into `ram`)
    -   `regs` is the register file, a `List(Int)` of length `num_regs`
    -   `ram` is the program encoded as a `List(Int)`
-   `num_regs = 4` is a named constant
    -   Using a name rather than a bare `4` makes the intent clear
    -   It appears in both the initialization and the tests without duplication

## Assembler

-   The assembler converts a list of `Op` values to a list of integers:

[%inc src/vm_demo.gleam mark=assemble_fn %]

-   Each instruction is packed into a single 24-bit integer
    -   Bits 23-16: [%g opcode "opcode" %] (0 = Halt, 1 = Load, 2 = Add, 3 = Jump, 4 = JumpIfZero)
    -   Bits 15-8: first operand
    -   Bits 7-0: second operand
-   `Load(0, 10)` encodes as `1 * field_size * field_size + 0 * field_size + 10 = 65546`
-   `field_size = 256` is a named constant representing one byte per instruction field;
    using it instead of bare `256` makes the encoding scheme explicit

## Executor

-   The executor is a single recursive function:

[%inc src/vm_demo.gleam mark=execute_fn %]

-   `list_at(machine.ram, machine.ip)` fetches the current instruction
-   `Error(_)` fires when the IP runs off the end: the machine halts
-   `Halt` stops execution cleanly and returns the current machine
-   Each other instruction builds a new `Machine` with updated state and recurses
-   `JumpIfZero` branches:
     if the register is zero, set IP to `addr`, otherwise advance by one
-   This is tail recursion again:
     every path either returns the machine or calls `execute` as the last action
    -   The Gleam compiler optimizes this to a loop,
        so even a long-running program will not overflow the call stack

## Running the Example

[%inc src/vm_demo.gleam mark=run_example %]

-   `Load(0, 10)` puts 10 in register 0; `Load(1, 20)` puts 20 in register 1
-   `Add(2, 0, 1)` stores `regs[0] + regs[1]` in register 2
-   `Halt` stops execution; final register state is `[10, 20, 30, 0]`

The disassembler converts the encoded program back to readable text:

```
load r0 10
load r1 20
add r2 r0 r1
halt
```

## Testing

[%inc test/vm_test.gleam mark=tests %]

-   `add_program_test` assembles and runs a simple addition program,
    then checks that register 2 holds the sum
-   `halt_at_start_test` confirms that `Halt` at IP 0 leaves the machine at IP 0
-   `jump_if_zero_skips_when_nonzero_test` checks that `JumpIfZero` does not branch
    when the register is non-zero, allowing the next instruction to execute

## Check Understanding

<details markdown="1">
<summary markdown="1">Why encode instructions as integers?</summary>

A real CPU stores programs as bytes in memory.
Using a `List(Int)` here mimics that:
the program and data live in the same address space,
and the instruction pointer is just an index.
This makes it straightforward to write self-modifying programs
(though doing so is a well-known source of bugs).
An alternative is to keep the `List(Op)` as the program representation,
which is simpler but means the program and data are separate.
This is less realistic but easier to reason about.

</details>

<details markdown="1">
<summary markdown="1">The `execute` function calls itself on every non-`Halt` instruction.
Why does Gleam not run out of stack space for a long program?</summary>

Because every recursive call to `execute` is a tail call:
`execute` is the last thing each branch does, with no further computation pending.
The Gleam compiler replaces tail calls with a jump back to the top of the function,
reusing the same stack frame.
This is equivalent to a `while` loop and uses O(1) stack space
regardless of how many instructions the program runs.

</details>

## Exercises

<div class="exercise" markdown="1">

### Sum 1 to 5 (20 minutes)

Write a program in `List(Op)` that computes `1 + 2 + 3 + 4 + 5 = 15`
using a loop and `JumpIfZero`.
Use register 0 as the counter (start at 5, decrement each iteration)
and register 1 as the accumulator.
Halt when the counter reaches zero.
Run it with `execute` and use `let assert` to verify register 1 holds `15`.

</div>

<div class="exercise" markdown="1">

### Disassembler (15 minutes)

Write `disassemble(words: List(Int)) -> List(String)` that converts
encoded words to strings like `"load r0 10"` and `"add r2 r0 r1"`.
Add one test per instruction type.

</div>

<div class="exercise" markdown="1">

### Multiply instruction (15 minutes)

Add `Mul(dst, a, b)` to `Op`.
Choose an unused opcode (e.g. 5).
Update `encode`, `decode`, `execute`, and (if you wrote it) the disassembler.
Write a test that loads 6 and 7 into registers, multiplies them,
and asserts the result is 42.

</div>

<div class="exercise" markdown="1">

### Step limit (10 minutes)

Add a `max_steps: Int` field to `Machine`.
Decrement it on each instruction; when it reaches zero, halt.
Change the return type to `Result(Machine, String)`.
Write a test that confirms a looping program returns an error after the
step limit is reached.

</div>
