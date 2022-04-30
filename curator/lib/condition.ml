open! Core
open! Async
open! Import

type t = {
  id: string;
  name: string;
  traits: Trait.t list;
  description: string;
  source: Source.t;
}
[@@deriving yojson_of]

let brand = Db.Brand.create "conditions"
let sourcePatcher : (module Patcher_intf.S with type t = Source.t) = Patcher.source_patcher "conditions"

module Param : Runner_intf.S = struct
  type inter = t
  type final = t [@@deriving yojson_of]

  let brand = brand
  let db_name = "conditionitems"

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
      and traits = Trait.spec in
      id, name, description, source, traits
    in
    let id, name, description, source, traits = Spec.resolve raw json in
    Some { id; name; description; traits; source }
  ;;

  let key ({ name; _ } : t) = name
  let finalize = Fn.id
end
