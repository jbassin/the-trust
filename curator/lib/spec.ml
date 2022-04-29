open! Core
open! Async
open! Import

module T = struct
  type 'a t = Json.t -> 'a

  let conv : (Json.t -> 'a) -> 'a t = Fn.id
  let resolve (t : 'a t) (json : Json.t) = t json
  let return : 'a -> 'a t = fun v _ -> v
  let map (t : 'a t) ~f : 'b t = fun json -> t json |> f

  let both (a : 'a t) (b : 'b t) : ('a * 'b) t =
   fun json ->
    let a = a json in
    let b = b json in
    a, b
 ;;

  let apply (f : ('a -> 'b) t) (v : 'a t) : 'b t =
   fun json ->
    let f = f json in
    let v = v json in
    f v
 ;;

  let map2 (lhs : 'a t) (rhs : 'b t) ~(f : 'a -> 'b -> 'c) : 'c t =
   fun json ->
    let lhs = lhs json in
    let rhs = rhs json in
    f lhs rhs
 ;;

  let map3 (fst : 'a t) (snd : 'b t) (trd : 'c t) ~(f : 'a -> 'b -> 'c -> 'd) : 'd t =
   fun json ->
    let fst = fst json in
    let snd = snd json in
    let trd = trd json in
    f fst snd trd
 ;;

  let all (ts : 'a t list) : 'a list t = fun json -> List.map ts ~f:(fun t -> t json)
  let all_unit (_ : unit t list) : unit t = return ()

  module Applicative_infix : Applicative.Applicative_infix with type 'a t := 'a t = struct
    let ( <*> ) = apply
    let ( *> ) _ t = t
    let ( <* ) t _ = t
    let ( >>| ) t f = map t ~f
  end

  include Applicative_infix
end

module Path = struct
  type t = string list

  let get_field (json : Json.t) field cast =
    match json with
    | `Assoc lst ->
      (match List.find lst ~f:(fun (name, _) -> String.equal field name) with
      | Some (_, field) -> cast field
      | None ->
        raise_s
          [%message
            "Unable to find field in json object" (json : Json.t) (field : string)])
    | json ->
      raise_s
        [%message "Json wasn't object, has no fields" (json : Json.t) (field : string)]
  ;;

  let path fields cast json =
    List.fold fields ~init:json ~f:(fun (json : Json.t) field ->
        get_field json field Fn.id)
    |> cast
  ;;

  let ( !! ) v = [ v ]
  let ( / ) (lhs : t) rhs : t = rhs :: lhs

  let ( > ) (lhs : t) (rhs : Json.t -> 'a) : 'a T.t =
    let lhs = List.rev lhs in
    path lhs rhs
  ;;
end

include T

module Rhs = struct
  let return = return
  let ( !! ) = Path.( !! )
  let ( / ) = Path.( / )
  let ( > ) : Path.t -> 'a t -> 'a t = Path.( > )
  let ( >> ) lhs rhs = lhs / "value" > rhs

  let list (cast : 'a t) : 'a list t = function
    | `List ts -> List.map ts ~f:(fun t -> cast t)
    | json -> raise_s [%message "failed to convert to list" (json : Json.t)]
  ;;

  let maybe (cast : 'a t) : 'a option t =
   fun json ->
    try Some (cast json) with
    | _ -> None
 ;;

  let int : int t = function
    | `Int t -> t
    | json -> raise_s [%message "failed to convert to integer" (json : Json.t)]
  ;;

  let bool : bool t = function
    | `Bool t -> t
    | json -> raise_s [%message "failed to convert to boolean" (json : Json.t)]
  ;;

  let string : string t = function
    | `String t -> t
    | json -> raise_s [%message "failed to convert to string" (json : Json.t)]
  ;;

  let id = !!"_id" > string
  let name = !!"name" > string
  let data = !!"data"
  let description = data / "description" >> string
end

include Rhs

include struct
  module Open_on_rhs_intf = struct
    module type S = module type of struct
      include Rhs
    end
  end

  module Let_syntax = struct
    let return = return

    include Applicative_infix

    module Let_syntax = struct
      let return = return
      let map = map
      let both = both

      module Open_on_rhs = Rhs
    end
  end
end
