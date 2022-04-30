open! Core
open! Async
open! Import

type t = {
  full_name: string;
  short_name: string;
  abbreviation: string;
  color: string option;
}
[@@deriving enumerate, yojson_of]

val missing : t
val is_missing : t -> bool
val find : abbr:string -> t option
val normalize : string -> t option
