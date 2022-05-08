open! Core
open! Async
open! Import
open! Feat

let brand = Db.Brand.create "archetype-feats"
let sourcePatcher : (module Patcher_intf.S with type t = Source.t) = Patcher.source_patcher "archetype-feats"

let source_of_archetype =
  let precomp = ref None in
  fun db feat ->
    let archetypes =
      match !precomp with
      | None ->
        let archetypes =
          Db.get db ~brand:Archetype.brand
          |> String.Map.data
          |> List.concat_map ~f:(fun { associated_feats; source; _ } ->
                 List.map associated_feats ~f:(fun feat -> normalize feat, source))
          |> String.Map.of_alist_multi
          |> String.Map.map ~f:List.hd_exn
        in
        precomp := Some archetypes;
        archetypes
      | Some archetypes -> archetypes
    in
    String.Map.find archetypes (normalize feat)
;;

let maybe_get_feat key ~db = Db.get db ~brand |> Fn.flip String.Map.find key

let rec source_of_prereq db feat =
  match Source.is_missing feat.source with
  | false -> Some feat.source
  | true ->
    (match List.filter_map feat.prerequisites ~f:(maybe_get_feat ~db) with
    | [] -> None
    | feats ->
      let sourced, unsourced = List.partition_tf feats ~f:(fun { source; _ } -> Source.is_missing source) in
      (match List.hd sourced with
      | Some { source; _ } -> Some source
      | None -> List.map unsourced ~f:(source_of_prereq db) |> List.hd |> Option.join))
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

  let steps =
    [
      (fun ~key:_ ~data ~db ~raw ->
        let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = sourcePatcher in
        match Source.is_missing data.source with
        | false -> data
        | true ->
          (match source_of_archetype db data.name with
          | None -> data
          | Some source ->
            SourcePatcher.forget raw;
            { data with source }));
      (fun ~key:_ ~data ~db ~raw ->
        let (module SourcePatcher : Patcher_intf.S with type t = Source.t) = sourcePatcher in
        match Source.is_missing data.source with
        | false -> data
        | true ->
          (match source_of_prereq db data with
          | None -> data
          | Some source ->
            SourcePatcher.forget raw;
            { data with source }));
    ]
  ;;

  let ingest = ingest sourcePatcher Archetype
  let key ({ name; _ } : inter) = name
  let finalize = Fn.id
end
