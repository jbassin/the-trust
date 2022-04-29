open! Core
open! Async
open! Import

module Category = struct
  type t =
    | None [@name "none"]
    | Defensive [@name "defensive"]
    | Offensive [@name "offensive"]
    | Passive [@name "passive"]
  [@@deriving yojson_of]

  let spec =
    let%map_open.Spec category = data / "actionCategory" >> string in
    match category with
    | "defensive" -> Defensive
    | "offensive" -> Offensive
    | "passive" -> Passive
    | _ -> None
  ;;
end

module Duration = struct
  type t =
    | Passive
    | Free
    | Reaction
    | Action of int
    | Range of
        { lower : t
        ; higher : t
        }

  let rec yojson_of_t : t -> Json.t = function
    | Passive -> `Assoc [ "kind", `String "passive" ]
    | Free -> `Assoc [ "kind", `String "free" ]
    | Reaction -> `Assoc [ "kind", `String "reaction" ]
    | Action quantity -> `Assoc [ "kind", `String "action"; "quantity", `Int quantity ]
    | Range { lower; higher } ->
      `Assoc
        [ "kind", `String "range"
        ; "lower", yojson_of_t lower
        ; "higher", yojson_of_t higher
        ]
  ;;

  let spec =
    let%map_open.Spec type_ = data / "actionType" >> string
    and quantity = data / "actions" >> maybe int in
    match type_, quantity with
    | "free", _ -> Free
    | "passive", _ -> Passive
    | "reaction", _ -> Reaction
    | "action", Some 2 -> Action 2
    | "action", Some 3 -> Action 3
    | "action", _ -> Action 1
    | _ ->
      eprintf
        "%s\n"
        (Sexp.to_string_hum
           [%message "unexpected action duration" type_ (quantity : int option)]);
      Action 1
  ;;
end

type t =
  { id : string
  ; name : string
  ; traits : Trait.t list
  ; description : string
  ; source : Source.t
  ; duration : Duration.t
  ; category : Category.t
  }
[@@deriving yojson_of]

let brand = Db.Brand.create "actions"

let sourcePatcher : (module Patcher_intf.S with type t = Source.t) =
  Patcher.source_patcher "actions"
;;

module Param : Runner_intf.S = struct
  type inter = t
  type final = t [@@deriving yojson_of]

  let brand = brand
  let db_name = "actions"

  let patchers : (module Patcher_intf.Inner) list =
    let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = sourcePatcher in
    [ (module SourcePatcher) ]
  ;;

  let steps = []

  let ingest json =
    let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = sourcePatcher in
    let raw =
      let%map_open.Spec id = id
      and name = name
      and description = description
      and source = SourcePatcher.patch
      and traits = Trait.spec
      and category = Category.spec
      and duration = Duration.spec in
      { id; name; description; source; traits; category; duration }
    in
    Some (Spec.resolve raw json)
  ;;

  let key ({ name; _ } : t) = name
  let finalize = Fn.id
end
