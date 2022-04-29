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
    [ "Acrobatics", "acr"
    ; "Arcana", "arc"
    ; "Athletics", "ath"
    ; "Crafting", "cra"
    ; "Deception", "dec"
    ; "Diplomacy", "dip"
    ; "Intimidation", "itm"
    ; "Medicine", "med"
    ; "Nature", "nat"
    ; "Occultism", "occ"
    ; "Performance", "prf"
    ; "Religion", "rel"
    ; "Society", "soc"
    ; "Stealth", "ste"
    ; "Survival", "sur"
    ; "Thievery", "thi"
    ]
    ~f:(fun (full_name, abbreviation) -> { full_name; abbreviation })
;;

let spec =
  let%map_open.Spec abbr = string in
  List.find_exn all ~f:(fun { abbreviation; _ } -> String.equal abbr abbreviation)
;;
