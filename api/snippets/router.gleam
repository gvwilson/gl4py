import gleam/dynamic
import gleam/http.{Delete, Get, Patch, Post}
import gleam/otp/process.{Subject}
import wisp.{type Request, type Response}

// mccole: router_fn
fn router(req: Request, todos_subject: Subject(Msg)) -> Response {
  case wisp.path_segments(req) {
    ["todos"] -> {
      case req.method {
        Get -> handle_get_all(todos_subject)
        Post -> handle_post(req, todos_subject)
        _ -> wisp.method_not_allowed([Get, Post])
      }
    }
    ["todos", id_str] -> {
      case req.method {
        Delete -> handle_delete(id_str, todos_subject)
        Patch -> handle_patch(id_str, req, todos_subject)
        _ -> wisp.method_not_allowed([Delete, Patch])
      }
    }
    _ -> wisp.not_found()
  }
}
// mccole: /router_fn

// mccole: decode_body_fn
fn decode_add_body(data: dynamic.Dynamic) -> Result(String, List(dynamic.DecodeError)) {
  dynamic.field("title", dynamic.string)(data)
}
// mccole: /decode_body_fn
