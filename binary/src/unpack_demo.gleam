import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/string

type Value {
  VInt(Int)
  VStr(String)
}

type Fmt {
  FInt
  FStr
}

// mccole: corrupt_demo
pub fn main() {
  let formats = [FStr, FInt]
  let values = [VStr("Ada"), VInt(30)]

  let packed = pack(formats, values)
  io.println("packed byte size: " <> int.to_string(bit_array.byte_size(packed)))

  let unpacked = unpack(formats, packed)
  io.println(string.inspect(unpacked))

  let corrupted = <<packed:bits, 255>>
  let failed = unpack(formats, corrupted)
  io.println(string.inspect(failed))
}

// mccole: /corrupt_demo

fn pack(formats: List(Fmt), values: List(Value)) -> BitArray {
  case formats, values {
    [], [] -> <<>>
    [FInt, ..frest], [VInt(n), ..vrest] -> <<n:32-big, pack(frest, vrest):bits>>
    [FStr, ..frest], [VStr(s), ..vrest] -> {
      let bytes = <<s:utf8>>
      let len = bit_array.byte_size(bytes)
      <<len:32-big, bytes:bits, pack(frest, vrest):bits>>
    }
    _, _ -> <<>>
  }
}

fn unpack(formats: List(Fmt), data: BitArray) -> Result(List(Value), String) {
  unpack_loop(formats, data, [])
}

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
      let assert Ok(s) = bit_array.to_string(str_data)
      unpack_loop(frest, rest, [VStr(s), ..acc])
    }
    _, _ -> Error("unexpected end of data")
  }
}
