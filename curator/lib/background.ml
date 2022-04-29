open! Core
open! Async
open! Import

module Boosts = struct
  type t =
    { first : Ability.t list
    ; second : Ability.t list
    }
  [@@deriving yojson_of]

  let spec =
    let boost = Spec.( / ) Spec.data "boosts" in
    let%map_open.Spec first = boost / "0" >> list Ability.spec
    and second = boost / "1" >> list Ability.spec in
    { first; second }
  ;;
end

type t =
  { id : string
  ; name : string
  ; traits : Trait.t list
  ; description : string
  ; source : Source.t
  ; skills : Skill.t list
  ; lore : string
  ; boosts : Boosts.t
  }
[@@deriving yojson_of]

let brand = Db.Brand.create "backgrounds"

let sourcePatcher : (module Patcher_intf.S with type t = Source.t) =
  Patcher.source_patcher "backgrounds"
;;

module Param : Runner_intf.S = struct
  type inter = t
  type final = t [@@deriving yojson_of]

  let brand = brand
  let db_name = "backgrounds"

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
      and skills = data / "trainedSkills" >> list Skill.spec
      and lore = data / "trainedLore" > string
      and boosts = Boosts.spec in
      { id; name; description; source; traits; skills; lore; boosts }
    in
    Some (Spec.resolve raw json)
  ;;

  let key ({ name; _ } : t) = name
  let finalize = Fn.id
end
