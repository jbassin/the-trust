open! Core
open! Async
open! Import

type t [@@deriving enumerate, yojson_of]

val spec : t Spec.t