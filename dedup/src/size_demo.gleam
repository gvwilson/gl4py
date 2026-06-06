import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

// mccole: fileinfo
type FileInfo {
  FileInfo(path: String, hash: String, size: Int)
}

// mccole: /fileinfo

pub fn main() {
  let files = [
    FileInfo("/a/one.txt", "abc123", 1024),
    FileInfo("/b/two.txt", "def456", 512),
    FileInfo("/c/three.txt", "abc123", 1024),
    FileInfo("/d/four.txt", "ghi789", 256),
    FileInfo("/e/five.txt", "abc123", 1024),
    FileInfo("/f/six.txt", "def456", 512),
  ]

  let #(groups, savings) = find_duplicates_with_size(files)
  io.println(string.inspect(groups))
  io.println("bytes that could be freed: " <> int.to_string(savings))
}

// mccole: size_fn
fn find_duplicates_with_size(
  files: List(FileInfo),
) -> #(List(List(String)), Int) {
  let grouped =
    list.fold(files, dict.new(), fn(acc, file) {
      let existing = dict.get(acc, file.hash)
      let paths = case existing {
        Ok(#(existing_paths, _)) -> [file.path, ..existing_paths]
        Error(_) -> [file.path]
      }
      dict.insert(acc, file.hash, #(paths, file.size))
    })

  let dup_groups =
    grouped
    |> dict.values
    |> list.filter(fn(entry) {
      let #(paths, _size) = entry
      list.length(paths) > 1
    })

  let dup_paths =
    list.map(dup_groups, fn(entry) {
      let #(paths, _size) = entry
      paths
    })

  let savings =
    dup_groups
    |> list.fold(0, fn(acc, entry) {
      let #(paths, size) = entry
      let copies = list.length(paths) - 1
      acc + size * copies
    })

  #(dup_paths, savings)
}
// mccole: /size_fn
