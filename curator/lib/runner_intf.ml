open! Core
open! Async
open! Import

module type S = sig
  type inter
  type final [@@deriving yojson_of]

  val brand : (inter * Json.t) String.Map.t Db.Brand.t
  val db_name : string
  val steps : (key:string -> data:inter -> db:Db.t -> raw:Json.t -> inter) list
  val patchers : (module Patcher_intf.Inner) list
  val ingest : Json.t -> inter option
  val key : inter -> string
  val finalize : inter -> final
end
