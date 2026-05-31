import argv
import filepath
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import simplifile

// mccole: args_fn
fn get_root() -> String {
  case argv.load().arguments {
    [path, ..] -> path
    [] ->
      simplifile.current_directory()
      |> result.unwrap(".")
  }
}
// mccole: /args_fn

// mccole: walk_fn
/// Recursively collect all regular files under `root`.
/// Returns a list of #(path, size) pairs.
/// Entries that cannot be read are silently skipped.
fn collect_files(root: String) -> List(#(String, Int)) {
  case simplifile.read_directory(at: root) {
    Error(_) -> []
    Ok(names) ->
      list.flat_map(names, fn(name) {
        let path = filepath.join(root, name)
        case simplifile.file_info(path) {
          Error(_) -> []
          Ok(info) ->
            case simplifile.file_info_type(info) {
              simplifile.File -> [#(path, info.size)]
              simplifile.Directory -> collect_files(path)
              _ -> []
            }
        }
      })
  }
}
// mccole: /walk_fn

// mccole: hash_fn
/// In production, use a crypto library (e.g. gleam_crypto) to compute
/// SHA-256 of the file's bytes. Here we read the file and use its
/// content directly so the example needs no extra dependencies.
fn hash_file(path: String) -> Result(String, String) {
  simplifile.read(path)
  |> result.map_error(simplifile.describe_error)
}
// mccole: /hash_fn

// mccole: run_fn
fn run(root: String) -> String {
  let entries =
    collect_files(root)
    |> list.flat_map(fn(entry) {
      let #(path, size) = entry
      case hash_file(path) {
        Ok(hash) -> [#(path, hash, size)]
        Error(_) -> []
      }
    })

  let #(groups, savings) = find_duplicates_with_size(entries)
  case groups {
    [] -> "no duplicates found"
    _ ->
      int.to_string(list.length(groups))
      <> " duplicate group(s); "
      <> int.to_string(savings)
      <> " bytes could be freed"
  }
}
// mccole: /run_fn

pub fn main() {
  let root = get_root()
  io.println("scanning: " <> root)
  io.println(run(root))
}

fn find_duplicates_with_size(
  files: List(#(String, String, Int)),
) -> #(List(List(String)), Int) {
  let grouped =
    list.fold(files, dict.new(), fn(acc, file) {
      let #(path, hash, size) = file
      let existing = dict.get(acc, hash)
      let paths = case existing {
        Ok(#(existing_paths, _)) -> [path, ..existing_paths]
        Error(_) -> [path]
      }
      dict.insert(acc, hash, #(paths, size))
    })

  let dup_groups =
    grouped
    |> dict.values
    |> list.filter(fn(entry) {
      let #(paths, _) = entry
      list.length(paths) > 1
    })

  let dup_paths = list.map(dup_groups, fn(entry) {
    let #(paths, _) = entry
    paths
  })

  let savings =
    list.fold(dup_groups, 0, fn(acc, entry) {
      let #(paths, size) = entry
      acc + size * { list.length(paths) - 1 }
    })

  #(dup_paths, savings)
}
