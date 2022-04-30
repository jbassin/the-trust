open! Core
open! Async
open! Import
open! Feat

let brand = Db.Brand.create "general-feats"

let sourcePatcher : (module Patcher_intf.S with type t = Source.t) =
  Patcher.source_patcher "general-feats"
;;

module Param : Runner_intf.S = struct
  type nonrec inter = inter
  type final = inter [@@deriving yojson_of]

  let brand = brand
  let db_name = "feats"

  let patchers : (module Patcher_intf.Inner) list =
    let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = sourcePatcher in
    [ (module SourcePatcher) ]
  ;;

  let steps = []
  let ingest = ingest sourcePatcher General
  let key ({ name; _ } : inter) = name
  let finalize = Fn.id
end
