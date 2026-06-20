import gleam/dynamic/decode
import gleam/list
import gleam/result
import sqlight.{type Connection}

// mccole: insert_todo_fn
fn insert_todo(conn: Connection, title: String) -> Result(Todo, String) {
  let sql = "INSERT INTO todos (title, done) VALUES (?, ?)"
  let params = [sqlight.text(title), sqlight.int(0)]
  case sqlight.query(sql, conn, params, row_decoder()) {
    Ok([todo, ..]) -> Ok(todo)
    Ok([]) -> Error("insert returned no rows")
    Error(e) -> Error(sqlight.error_to_string(e))
  }
}
// mccole: /insert_todo_fn

// mccole: row_decoder_fn
fn row_decoder() -> decode.Decoder(Todo) {
  use id <- decode.field(0, decode.int)
  use title <- decode.field(1, decode.string)
  use done <- decode.field(2, decode.int)
  decode.success(Todo(id, title, done == 1))
}
// mccole: /row_decoder_fn

// mccole: migrations_fn
fn run_migrations(conn: Connection) -> Result(Nil, String) {
  let migrations = [
    "CREATE TABLE IF NOT EXISTS todos (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       title TEXT NOT NULL,
       done INTEGER NOT NULL DEFAULT 0
     )",
  ]
  list.try_each(migrations, fn(sql) {
    sqlight.exec(sql, conn)
    |> result.map_error(sqlight.error_to_string)
  })
}
// mccole: /migrations_fn
