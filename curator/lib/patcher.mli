open! Core
open! Async
open! Import
open! Patcher_intf
module Make (P : P) : S with type t = P.t

val source_patcher : string -> (module S with type t = Source.t)