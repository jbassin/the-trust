open! Core
open! Async
open! Import

module Brand = struct
  type 'a t =
    { key : 'a Hmap.key
    ; name : string
    }

  let create name = { key = Hmap.Key.create (); name }
  let file { name; _ } = name
end

type t = { mutable db : Hmap.t }

let create () = { db = Hmap.empty }
let get { db } ~brand = Hmap.get brand.Brand.key db |> String.Map.map ~f:fst
let set t ~brand ~data = t.db <- Hmap.add brand.Brand.key data t.db

let append t ~brand ~key ~data =
  match Hmap.find brand.Brand.key t.db with
  | None -> t.db <- Hmap.add brand.key (String.Map.singleton key data) t.db
  | Some map -> t.db <- Hmap.add brand.key (String.Map.set map ~key ~data) t.db
;;

let modify t ~brand ~f =
  match Hmap.find brand.Brand.key t.db with
  | None -> ()
  | Some map ->
    let map =
      String.Map.mapi map ~f:(fun ~key ~data:(data, raw) ->
          let data = f ~key ~data ~db:t ~raw in
          data, raw)
    in
    t.db <- Hmap.add brand.key map t.db
;;
