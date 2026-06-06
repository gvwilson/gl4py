import gleam/bit_array
import gleam/io
import gleam/list
import gleam/string

// mccole: value_types
pub type Value {
  VInt(Int)
  VStr(String)
}

pub type Fmt {
  FInt
  FStr
}

// mccole: /value_types

pub fn main() {
  let formats = [FInt, FStr, FInt]
  let values = [VInt(42), VStr("Gleam"), VInt(99)]

  let packed = pack(formats, values)
  io.println(string.inspect(packed))

  let unpacked = unpack(formats, packed)
  io.println(string.inspect(unpacked))
}

// mccole: pack_fn
pub fn pack(formats: List(Fmt), values: List(Value)) -> BitArray {
  case formats, values {
    [], [] -> <<>>
    [FInt, ..frest], [VInt(n), ..vrest] -> <<n:32-big, pack(frest, vrest):bits>>
    [FStr, ..frest], [VStr(s), ..vrest] -> {
      let bytes = string_to_bytes(s)
      let len = bit_array.byte_size(bytes)
      <<len:32-big, bytes:bits, pack(frest, vrest):bits>>
    }
    _, _ -> <<>>
  }
}

// mccole: /pack_fn

pub fn unpack(
  formats: List(Fmt),
  data: BitArray,
) -> Result(List(Value), String) {
  unpack_loop(formats, data, [])
}

// mccole: unpack_fn
fn unpack_loop(
  formats: List(Fmt),
  data: BitArray,
  acc: List(Value),
) -> Result(List(Value), String) {
  case formats, data {
    [], _ -> Ok(list.reverse(acc))
    [FInt, ..frest], <<n:32-big, rest:bits>> ->
      unpack_loop(frest, rest, [VInt(n), ..acc])
    [FStr, ..frest], <<len:32-big, str_data:bytes-size(len), rest:bits>> -> {
      let s = str_data |> bytes_to_string
      unpack_loop(frest, rest, [VStr(s), ..acc])
    }
    _, _ -> Error("unexpected end of data")
  }
}

// mccole: /unpack_fn

fn string_to_bytes(s: String) -> BitArray {
  <<s:utf8>>
}

fn bytes_to_string(data: BitArray) -> String {
  let assert Ok(s) = bit_array.to_string(data)
  s
}
