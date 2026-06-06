import gleeunit
import gleeunit/should
import pack_demo.{type Fmt, type Value, FInt, FStr, VInt, VStr, pack, unpack}

pub fn main() {
  gleeunit.main()
}

// mccole: examples
pub fn roundtrip_int_test() {
  let formats = [FInt]
  let values = [VInt(42)]
  pack(formats, values)
  |> unpack(formats, _)
  |> should.equal(Ok([VInt(42)]))
}

pub fn roundtrip_string_test() {
  let formats = [FStr]
  let values = [VStr("Gleam")]
  pack(formats, values)
  |> unpack(formats, _)
  |> should.equal(Ok([VStr("Gleam")]))
}

pub fn roundtrip_mixed_test() {
  let formats = [FInt, FStr, FInt]
  let values = [VInt(1), VStr("hello"), VInt(2)]
  pack(formats, values)
  |> unpack(formats, _)
  |> should.equal(Ok(values))
}

// mccole: /examples

pub fn empty_roundtrip_test() {
  pack([], [])
  |> unpack([], _)
  |> should.equal(Ok([]))
}

pub fn truncated_data_test() {
  unpack([FInt], <<0:8>>)
  |> should.be_error()
}
