import gleam/int
import gleam_httpc as httpc

// mccole: fetch_issues_fn
fn fetch_issues(
  owner: String,
  repo: String,
) -> Result(List(Issue), String) {
  let url = "https://api.github.com/repos/" <> owner <> "/" <> repo <> "/issues"
  case httpc.get(url) {
    Error(e) -> Error("network error: " <> httpc.error_to_string(e))
    Ok(response) -> {
      case response.status {
        200 -> decode_issues(response.body)
        status ->
          Error("unexpected status: " <> int.to_string(status))
      }
    }
  }
}
// mccole: /fetch_issues_fn
