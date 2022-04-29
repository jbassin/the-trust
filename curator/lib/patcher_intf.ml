open! Core
open! Async
open! Import

module type P = sig
  type t

  val name : string
  val kind : string
  val default : t
  val key : Json.t -> string
  val accessor : t option Spec.t
  val lookup : string -> t option
end

module type Inner = sig
  type t

  val init : string -> unit Deferred.t
  val patch : t Spec.t
  val forget : Json.t -> unit
  val save : string -> unit Deferred.t
end

module type S = sig
  include Inner
  module Erased : Inner
end
