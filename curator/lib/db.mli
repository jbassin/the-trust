open! Core
open! Async
open! Import

module Brand : sig
  type 'a t

  val create : string -> _ t
  val file : _ t -> string
end

type t

val create : unit -> t
val get : t -> brand:('a * Json.t) String.Map.t Brand.t -> 'a String.Map.t

val set
  :  t
  -> brand:('a * Json.t) String.Map.t Brand.t
  -> data:('a * Json.t) String.Map.t
  -> unit

val append
  :  t
  -> brand:('a * Json.t) String.Map.t Brand.t
  -> key:string
  -> data:'a * Json.t
  -> unit

val modify
  :  t
  -> brand:('a * Json.t) String.Map.t Brand.t
  -> f:(key:string -> data:'a -> db:t -> raw:Json.t -> 'a)
  -> unit
