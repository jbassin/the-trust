open! Core
open! Async
open! Import

type inter = {
  id: string;
  name: string;
  description: string;
  associated_feats: string list;
  source: Source.t;
}
[@@deriving yojson_of]

let brand = Db.Brand.create "archetypes"
let sourcePatcher : (module Patcher_intf.S with type t = Source.t) = Patcher.source_patcher "archetypes"

module Param : Runner_intf.S = struct
  type nonrec inter = inter
  type final = inter [@@deriving yojson_of]

  let brand = brand
  let db_name = "archetypes"

  let patchers : (module Patcher_intf.Inner) list =
    let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = sourcePatcher in
    [ (module SourcePatcher) ]
  ;;

  let steps = []

  let re =
    let open Re in
    seq [ str "pf2e.feats-srd."; group (shortest (rep1 any)); str "]" ] |> compile
  ;;

  let ingest json =
    let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = sourcePatcher in
    let raw =
      let%map_open.Spec id = id
      and name = name
      and description = !!"content" > string
      and source = SourcePatcher.patch in
      let associated_feats =
        Re.all re description |> List.map ~f:(Fn.flip Re.Group.get 1) |> List.dedup_and_sort ~compare:String.compare
      in
      { id; name; description; source; associated_feats }
    in
    Some (Spec.resolve raw json)
  ;;

  let key ({ name; _ } : inter) = name
  let finalize = Fn.id
end
