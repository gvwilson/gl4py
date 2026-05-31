import gleam/int
import gleam/io
import gleam/list
import gleam/string

const num_regs = 4

// Each instruction field occupies one byte (values 0–255).
const field_size = 256

// mccole: op_machine_type
pub type Op {
  Halt
  Load(Int, Int)
  Add(Int, Int, Int)
  Jump(Int)
  JumpIfZero(Int, Int)
}

pub type Machine {
  Machine(ip: Int, regs: List(Int), ram: List(Int))
}
// mccole: /op_machine_type

pub fn main() {
  // mccole: run_example
  let program = [
    Load(0, 10),
    Load(1, 20),
    Add(2, 0, 1),
    Halt,
  ]
  let machine = Machine(ip: 0, regs: list.repeat(0, num_regs), ram: assemble(program))
  let result = execute(machine)
  io.println(string.inspect(result.regs))
  // mccole: /run_example

  let dis = disassemble(assemble(program))
  list.each(dis, io.println)
}

// mccole: assemble_fn
pub fn assemble(ops: List(Op)) -> List(Int) {
  list.map(ops, encode)
}

fn encode(op: Op) -> Int {
  case op {
    Halt -> 0
    Load(reg, val) -> 1 * field_size * field_size + reg * field_size + val
    Add(dst, a, b) -> 2 * field_size * field_size + dst * field_size + a * 16 + b
    Jump(addr) -> 3 * field_size * field_size + addr
    JumpIfZero(reg, addr) -> 4 * field_size * field_size + reg * field_size + addr
  }
}
// mccole: /assemble_fn

// mccole: execute_fn
pub fn execute(machine: Machine) -> Machine {
  case list_at(machine.ram, machine.ip) {
    Error(_) -> machine
    Ok(encoded) -> {
      let op = decode(encoded)
      case op {
        Halt -> machine
        Load(reg, val) -> {
          let new_regs = set_reg(machine.regs, reg, val)
          execute(Machine(machine.ip + 1, new_regs, machine.ram))
        }
        Add(dst, a, b) -> {
          let va = get_reg(machine.regs, a)
          let vb = get_reg(machine.regs, b)
          let new_regs = set_reg(machine.regs, dst, va + vb)
          execute(Machine(machine.ip + 1, new_regs, machine.ram))
        }
        Jump(addr) ->
          execute(Machine(addr, machine.regs, machine.ram))
        JumpIfZero(reg, addr) -> {
          case get_reg(machine.regs, reg) {
            0 -> execute(Machine(addr, machine.regs, machine.ram))
            _ -> execute(Machine(machine.ip + 1, machine.regs, machine.ram))
          }
        }
      }
    }
  }
}
// mccole: /execute_fn

fn decode(word: Int) -> Op {
  let opcode = word / field_size / field_size
  case opcode {
    0 -> Halt
    1 -> {
      let reg = word / field_size % field_size
      let val = word % field_size
      Load(reg, val)
    }
    2 -> {
      let dst = word / field_size % field_size
      let a = word % field_size / 16
      let b = word % field_size % 16
      Add(dst, a, b)
    }
    3 -> {
      let addr = word % { field_size * field_size }
      Jump(addr)
    }
    4 -> {
      let reg = word / field_size % field_size
      let addr = word % field_size
      JumpIfZero(reg, addr)
    }
    _ -> Halt
  }
}

fn disassemble(words: List(Int)) -> List(String) {
  list.map(words, fn(w) {
    let op = decode(w)
    case op {
      Halt -> "halt"
      Load(reg, val) ->
        "load r" <> int.to_string(reg) <> " " <> int.to_string(val)
      Add(dst, a, b) ->
        "add r"
        <> int.to_string(dst)
        <> " r"
        <> int.to_string(a)
        <> " r"
        <> int.to_string(b)
      Jump(addr) -> "jump " <> int.to_string(addr)
      JumpIfZero(reg, addr) ->
        "jz r" <> int.to_string(reg) <> " " <> int.to_string(addr)
    }
  })
}

fn list_at(lst: List(a), idx: Int) -> Result(a, Nil) {
  list.drop(lst, idx) |> list.first
}

fn get_reg(regs: List(Int), idx: Int) -> Int {
  case list_at(regs, idx) {
    Ok(v) -> v
    Error(_) -> 0
  }
}

fn set_reg(regs: List(Int), idx: Int, val: Int) -> List(Int) {
  list.index_map(regs, fn(v, i) { case i == idx { True -> val  False -> v } })
}
