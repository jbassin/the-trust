open! Core
open! Async
open! Import
open! Runner_intf

val run
  :  (module S) list
  -> patch_path:string
  -> db_path:string
  -> data_path:string
  -> unit Deferred.t
