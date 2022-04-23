open! Core
open! Async
open! Import

module type P = sig
  type t

  val name : string
  val kind : string
  val default : t
  val key : Json.t -> string
  val accessor : Json.t -> t option
  val lookup : string -> t option
end

module type S = sig
  type t

  val init : string -> unit Deferred.t
  val patch : Json.t -> t
  val forget : Json.t -> unit
  val save : string -> unit Deferred.t
end