open! Core
open! Async
open! Import

type t = {
  id: string;
  name: string;
  traits: Trait.t list;
  description: string;
  source: Source.t;
}

val brand : (t * Json.t) Core.String.Map.t Db.Brand.t

module Param : Runner_intf.S
