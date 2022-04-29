open! Core
open! Async
open! Import
open! Runner_intf

module Step = struct
  type t =
    | Continue
    | Done
end

type t = { db : Db.t }

let create () = { db = Db.create () }

let init _ (module P : S) ~patch_path =
  Deferred.List.iter P.patchers ~f:(fun (module P : Patcher_intf.Inner) ->
      P.init patch_path)
;;

let ingest { db } (module P : S) ~db_path =
  let db_path = [%string "%{db_path}/%{P.db_name}.db"] in
  let%bind files = Async_unix.Sys.ls_dir db_path in
  Deferred.List.iter files ~f:(fun file ->
      let%bind contents = Reader.file_contents [%string "%{db_path}/%{file}"] in
      let raw = Json.from_string ~fname:file contents in
      match P.ingest raw with
      | None -> return ()
      | Some data ->
        Db.append db ~brand:P.brand ~key:(P.key data) ~data:(data, raw);
        return ())
;;

let step { db } (module P : S) ~step =
  if step < List.length P.steps
  then (
    Db.modify db ~brand:P.brand ~f:(List.nth_exn P.steps step);
    Step.Continue)
  else Step.Done
;;

let save { db } (module P : S) ~patch_path ~data_path =
  let data_path = [%string "%{data_path}/%{Db.Brand.file P.brand}.json"] in
  let data =
    Db.get db ~brand:P.brand
    |> String.Map.data
    |> List.map ~f:P.finalize
    |> List.map ~f:P.yojson_of_final
  in
  let contents = Json.pretty_to_string (`List data) in
  let%bind () = Writer.save data_path ~contents in
  Deferred.List.iter P.patchers ~f:(fun (module P : Patcher_intf.Inner) ->
      P.save patch_path)
;;

let run params ~patch_path ~db_path ~data_path =
  let t = create () in
  let%bind () = Deferred.List.iter params ~f:(fun param -> init t param ~patch_path) in
  let%bind () = Deferred.List.iter params ~f:(fun param -> ingest t param ~db_path) in
  let queue = List.map params ~f:(fun p -> p, 0) |> Queue.of_list in
  let rec loop () =
    match Queue.dequeue queue with
    | None -> ()
    | Some (p, idx) ->
      (match step t p ~step:idx with
      | Done -> loop ()
      | Continue ->
        Queue.enqueue queue (p, idx + 1);
        loop ())
  in
  loop ();
  Deferred.List.iter params ~f:(fun param -> save t param ~patch_path ~data_path)
;;
