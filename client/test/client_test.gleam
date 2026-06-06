import decode_demo.{Issue, issue_decoder}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn decode_one_issue_test() {
  let json_str = "{\"number\":1,\"title\":\"fix bug\",\"state\":\"open\"}"
  json.parse(json_str, issue_decoder())
  |> should.equal(Ok(Issue(1, "fix bug", "open")))
}

pub fn decode_list_test() {
  let json_str = "[{\"number\":1,\"title\":\"a\",\"state\":\"open\"}]"
  json.parse(json_str, decode.list(issue_decoder()))
  |> should.be_ok
  |> list.length
  |> should.equal(1)
}

pub fn missing_field_test() {
  let json_str = "{\"number\":1,\"title\":\"a\"}"
  json.parse(json_str, issue_decoder())
  |> should.be_error
}

pub fn wrong_type_test() {
  let json_str =
    "{\"number\":\"not an int\",\"title\":\"a\",\"state\":\"open\"}"
  json.parse(json_str, issue_decoder())
  |> should.be_error
}
// mccole: /tests
