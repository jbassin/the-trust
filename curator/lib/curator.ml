open! Core
open! Import

let command =
  Async.Command.async
    ~summary:"Generates the data"
    (let%map_open.Command patch_path =
       flag
         "-patch-path"
         (required Filename.arg_type)
         ~doc:"DIR path where the patches are stored"
     and db_path =
       flag
         "-db-path"
         (required Filename.arg_type)
         ~doc:"DIR path where the uncleaned data is located"
     and data_path =
       flag
         "-data-path"
         (required Filename.arg_type)
         ~doc:"DIR path where the data is stored"
     in
     fun () ->
       Runner.run
         [ (module Action.Param); (module Background.Param); (module Condition.Param) ]
         ~patch_path
         ~db_path
         ~data_path)
;;
