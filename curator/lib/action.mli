open! Core
open! Async
open! Import

module Category : sig
  type t =
    | None
    | Defensive
    | Offensive
    | Passive
end

module Duration : sig
  type t =
    | Passive
    | Free
    | Reaction
    | Action of int
    | Range of
        { lower : t
        ; higher : t
        }
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

val brand : (t * Json.t) Core.String.Map.t Db.Brand.t

module Param : Runner_intf.S
