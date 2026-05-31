import gleam/list
import gleeunit
import gleeunit/should
import room_demo.{Join, Leave, Say, handle_message, list_users, new_room}

pub fn main() {
  gleeunit.main()
}

// mccole: tests
pub fn join_test() {
  let room = new_room([]) |> handle_message(Join("alice"))
  list_users(room)
  |> should.equal(["alice"])
}

pub fn leave_test() {
  let room =
    new_room([])
    |> handle_message(Join("alice"))
    |> handle_message(Join("bob"))
    |> handle_message(Leave("alice"))
  list_users(room)
  |> should.equal(["bob"])
}

pub fn history_cap_test() {
  let room =
    list.fold(list.repeat("msg", 25), new_room([]), fn(r, msg) {
      handle_message(r, Say("alice", msg))
    })
  list.length(room.messages)
  |> should.equal(20)
}
// mccole: /tests
