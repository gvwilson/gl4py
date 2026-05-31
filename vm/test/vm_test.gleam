import gleam/list
import gleeunit
import gleeunit/should
import vm_demo.{Add, Halt, JumpIfZero, Load, Machine, assemble, execute}

fn at(lst: List(a), idx: Int) -> Result(a, Nil) {
  list.drop(lst, idx) |> list.first
}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn add_program_test() {
  let program = [Load(0, 5), Load(1, 3), Add(2, 0, 1), Halt]
  let machine = Machine(ip: 0, regs: list.repeat(0, 4), ram: assemble(program))
  let result = execute(machine)
  at(result.regs, 2)
  |> should.equal(Ok(8))
}

pub fn halt_at_start_test() {
  let program = [Halt]
  let machine = Machine(ip: 0, regs: list.repeat(0, 4), ram: assemble(program))
  let result = execute(machine)
  result.ip
  |> should.equal(0)
}

pub fn jump_if_zero_skips_when_nonzero_test() {
  // Load 1 into r0, then JumpIfZero r0 addr=0 should NOT jump
  let program = [Load(0, 1), JumpIfZero(0, 0), Load(1, 42), Halt]
  let machine = Machine(ip: 0, regs: list.repeat(0, 4), ram: assemble(program))
  let result = execute(machine)
  at(result.regs, 1)
  |> should.equal(Ok(42))
}
// mccole: /tests
