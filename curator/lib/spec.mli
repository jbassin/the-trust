open! Core
open! Async
open! Import

type 'a t

val conv : (Json.t -> 'a) -> 'a t
val resolve : 'a t -> Json.t -> 'a

module Rhs : sig
  val return : 'a -> 'a t
  val ( !! ) : string -> string list
  val ( / ) : string list -> string -> string list
  val ( > ) : string list -> 'a t -> 'a t
  val ( >> ) : string list -> 'a t -> 'a t
  val list : 'a t -> 'a list t
  val int : int t
  val bool : bool t
  val string : string t
  val id : string t
  val name : string t
  val data : string list
  val description : string t
end

include module type of struct
  include Rhs
end

include Applicative.S with type 'a t := 'a t

module Let_syntax : sig
  type 'a t

  val return : 'a -> 'a t

  include Applicative.Applicative_infix with type 'a t := 'a t

  module Let_syntax : sig
    type 'a t

    val return : 'a -> 'a t
    val map : 'a t -> f:('a -> 'b) -> 'b t
    val both : 'a t -> 'b t -> ('a * 'b) t

    module Open_on_rhs = Rhs
  end
  with type 'a t := 'a t
end
with type 'a t := 'a t
