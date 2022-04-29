open! Core
open! Async
open! Import

type t =
  { full_name : string
  ; abbreviation : string
  }
[@@deriving yojson_of]

let all =
  List.map
    [ "Charisma", "cha"
    ; "Constitution", "con"
    ; "Dexterity", "dex"
    ; "Intelligence", "int"
    ; "Strength", "str"
    ; "Wisdom", "wis"
    ]
    ~f:(fun (full_name, abbreviation) -> { full_name; abbreviation })
;;

let spec =
  let%map_open.Spec abbr = string in
  List.find_exn all ~f:(fun { abbreviation; _ } -> String.equal abbr abbreviation)
;;
