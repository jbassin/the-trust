open! Core
open! Async
open! Import

module Kind : sig
  type t =
    | Ancestry
    | Archetype
    | Bonus
    | Class
    | Feature
    | General
    | Skill
  [@@deriving yojson_of]

  val spec : t Spec.t
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
[@@deriving yojson_of]

val ingest
  :  (module Patcher_intf.S with type t = Source.t)
  -> Kind.t
  -> Json.t
  -> inter option
