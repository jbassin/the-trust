open! Core
open! Async
open! Import

module Kind = struct
  type t =
    | Rarity [@name "rarity"]
    | Standard [@name "standard"]
  [@@deriving yojson_of]
end

type raw =
  { rarity : string
  ; value : string list
  }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type t =
  { kind : Kind.t
  ; name : string
  }
[@@deriving fields, yojson_of]

let normalize = function
  | ("" | "common" | "uncommon" | "rare" | "unique") as name -> { name; kind = Rarity }
  | name -> { name; kind = Standard }
;;

let spec =
  let%map_open.Spec rarity = data / "traits" / "rarity" > string
  and values = data / "traits" >> list string in
  normalize rarity :: List.map values ~f:normalize
;;
