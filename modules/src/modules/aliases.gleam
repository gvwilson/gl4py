import gleam/dict

// mccole: type_aliases
pub type Filename = String
pub type Hash = String
pub type FileMap = dict.Dict(Hash, List(Filename))
// mccole: /type_aliases
