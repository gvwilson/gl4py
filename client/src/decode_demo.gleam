import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/string

// mccole: issue_type
pub type Issue {
  Issue(number: Int, title: String, state: String)
}
// mccole: /issue_type

pub fn main() {
  let json_str =
    "[
    {\"number\": 1, \"title\": \"add docs\", \"state\": \"open\"},
    {\"number\": 2, \"title\": \"fix typo\", \"state\": \"closed\"},
    {\"number\": 3, \"title\": \"add tests\", \"state\": \"open\"}
  ]"

  io.println("raw JSON:")
  io.println(json_str)

  let decoded = decode_issues(json_str)
  io.println("decoded:")
  io.println(string.inspect(decoded))

  io.println("open issues only:")
  case decoded {
    Ok(issues) -> {
      let open = list.filter(issues, fn(i) { i.state == "open" })
      io.println(string.inspect(open))
    }
    Error(e) -> io.println(e)
  }
}

// mccole: decode_fn
pub fn decode_issues(json_str: String) -> Result(List(Issue), String) {
  case json.parse(json_str, decode.list(issue_decoder())) {
    Ok(issues) -> Ok(issues)
    Error(e) -> Error("decode failed: " <> string.inspect(e))
  }
}
// mccole: /decode_fn

// mccole: decoder_fn
pub fn issue_decoder() -> decode.Decoder(Issue) {
  use number <- decode.field("number", decode.int)
  use title <- decode.field("title", decode.string)
  use state <- decode.field("state", decode.string)
  decode.success(Issue(number, title, state))
}
// mccole: /decoder_fn
