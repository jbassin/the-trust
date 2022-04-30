open! Core
open! Async

let normalize str = String.lowercase str |> String.strip
let err sexp = eprintf "%s\n" (Sexp.to_string_hum sexp)

module Json = struct
  include Yojson.Safe

  type t =
    [ `Assoc of (string * t) list
    | `Bool of bool
    | `Float of float
    | `Int of int
    | `Intlit of string
    | `List of t list
    | `Null
    | `String of string
    | `Tuple of t list
    | `Variant of string * t option
    ]
  [@@deriving sexp]
end

module Yaml = struct
  open Yaml

  type t =
    [ `Null
    | `Bool of bool
    | `Float of float
    | `String of string
    | `A of t list
    | `O of (string * t) list
    ]
  [@@deriving sexp]

  let to_string t = to_string_exn ~layout_style:`Block t
  let of_string str = of_string_exn str
end
