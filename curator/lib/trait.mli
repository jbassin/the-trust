open! Core
open! Async
open! Import

module Kind : sig
  type t =
    | Rarity
    | Standard
  [@@deriving yojson_of]
end

type raw =
  { rarity : string
  ; value : string list
  }
[@@deriving of_yojson]

type t =
  { kind : Kind.t
  ; name : string
  }
[@@deriving yojson_of]

val spec : t list Spec.t