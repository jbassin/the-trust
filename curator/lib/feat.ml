open! Core
open! Async
open! Import

module Kind = struct
  type t =
    | Ancestry [@name "ancestry"]
    | Archetype [@name "archetype"]
    | Bonus [@name "bonus"]
    | Class [@name "class"]
    | Feature [@name "feature"]
    | General [@name "general"]
    | Skill [@name "skill"]
  [@@deriving equal, yojson_of]

  let spec =
    let%map_open.Spec kind = data / "featType" >> string in
    match kind with
    | "ancestry" -> Ancestry
    | "archetype" -> Archetype
    | "bonus" -> Bonus
    | "class" -> Class
    | "classfeature" -> Feature
    | "general" -> General
    | "skill" -> Skill
    | _ ->
      eprintf "%s\n" (Sexp.to_string_hum [%message "unexpected feat kind" kind]);
      General
  ;;
end

type inter =
  { id : string
  ; name : string
  ; kind : Kind.t
  ; level : int
  ; description : string
  ; prerequisites : string list
  ; category : Action.Category.t
  ; duration : Action.Duration.t
  ; traits : Trait.t list
  ; source : Source.t
  }
[@@deriving fields, yojson_of]

let ingest (patcher : (module Patcher_intf.S with type t = Source.t)) filter_kind json =
  let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = patcher in
  let raw =
    let%map_open.Spec id = id
    and name = name
    and level = data / "level" >> int
    and kind = Kind.spec
    and description = description
    and prerequisites = data / "prerequisites" >> list (!!"value" > string)
    and category = Action.Category.spec
    and duration = Action.Duration.spec
    and traits = Trait.spec
    and source = SourcePatcher.patch in
    if Kind.equal kind filter_kind
    then
      Some
        { id
        ; name
        ; kind
        ; level
        ; description
        ; prerequisites
        ; category
        ; duration
        ; traits
        ; source
        }
    else (
      SourcePatcher.forget json;
      None)
  in
  Spec.resolve raw json
;;
