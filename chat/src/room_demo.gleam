import gleam/io
import gleam/list
import gleam/string

pub type Msg {
  Say(String, String)
  Join(String)
  Leave(String)
}

pub fn main() {
  io.println("starting chat simulation")
  io.println("---")

  // mccole: sim_demo
  let room = new_room([])
  let room = handle_message(room, Join("alice"))
  let room = handle_message(room, Join("bob"))
  let room = handle_message(room, Say("alice", "hello everyone"))
  let room = handle_message(room, Say("bob", "hi alice!"))
  let room = handle_message(room, Leave("alice"))
  io.println("users: " <> string.inspect(list_users(room)))
  // mccole: /sim_demo
}

// mccole: room_type
pub type Room {
  Room(name: String, users: List(String), messages: List(#(String, String)))
}

// mccole: /room_type

pub fn new_room(messages: List(#(String, String))) -> Room {
  Room("main", [], messages)
}

// mccole: handle_fn
pub fn handle_message(room: Room, msg: Msg) -> Room {
  case msg {
    Join(name) -> {
      io.println(name <> " joined the room")
      Room(room.name, [name, ..room.users], room.messages)
    }
    Leave(name) -> {
      io.println(name <> " left the room")
      Room(
        room.name,
        list.filter(room.users, fn(u) { u != name }),
        room.messages,
      )
    }
    Say(from, text) -> {
      io.println(from <> ": " <> text)
      let new_messages = [#(from, text), ..room.messages]
      case list.length(new_messages) > 20 {
        True -> Room(room.name, room.users, list.take(new_messages, 20))
        False -> Room(room.name, room.users, new_messages)
      }
    }
  }
}

// mccole: /handle_fn

pub fn list_users(room: Room) -> List(String) {
  list.reverse(room.users)
}
