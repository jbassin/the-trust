open! Core
open! Async
open! Import

module Boosts : sig
  type t =
    { first : Ability.t list
    ; second : Ability.t list
    }
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

val brand : (t * Json.t) Core.String.Map.t Db.Brand.t

module Param : Runner_intf.S
