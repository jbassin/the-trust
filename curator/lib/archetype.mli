open! Core
open! Async
open! Import

type inter = {
  id: string;
  name: string;
  description: string;
  associated_feats: string list;
  source: Source.t;
}

val brand : (inter * Json.t) Core.String.Map.t Db.Brand.t

module Param : Runner_intf.S
