open! Core
open! Async
open! Import
open! Patcher_intf

module Info = struct
  type t = {
    mutable computed: string option String.Map.t;
    mutable manual: string String.Map.t;
  }
  [@@deriving sexp]

  let yaml_of_t { computed; manual } : Yaml.t =
    let computed =
      `O
        (String.Map.to_alist computed
        |> List.map ~f:(fun (key, value) ->
               let value =
                 match value with
                 | None -> `Null
                 | Some str -> `String str
               in
               key, value))
    in
    let manual = `O (String.Map.to_alist manual |> List.map ~f:(fun (key, value) -> key, `String value)) in
    `O [ "computed", computed; "manual", manual ]
  ;;

  let t_of_yaml (yaml : Yaml.t) : t =
    match yaml with
    | `O [ ("computed", `O computed); ("manual", `O manual) ] ->
      let computed =
        List.map computed ~f:(fun (key, value) ->
            match value with
            | `Null -> key, None
            | `String value -> key, Some value
            | _ -> raise_s [%message "failed to parse value" (value : Yaml.t)])
        |> String.Map.of_alist_exn
      in
      let manual =
        List.map manual ~f:(fun (key, value) ->
            match value with
            | `String value -> key, value
            | _ -> raise_s [%message "failed to parse value" (value : Yaml.t)])
        |> String.Map.of_alist_exn
      in
      { computed; manual }
    | _ -> raise_s [%message "failed to read yaml" (yaml : Yaml.t)]
  ;;

  let create () = { computed = String.Map.empty; manual = String.Map.empty }
end

module Make (P : P) : S with type t = P.t = struct
  module T = struct
    type t = P.t

    type internal = {
      path: string;
      mutable prev_info: Info.t;
      next_info: Info.t;
    }

    let internal =
      let path = [%string "%{P.name}-%{P.kind}.yml"] in
      { path; prev_info = Info.create (); next_info = Info.create () }
    ;;

    let init path =
      match%bind Monitor.try_with ~run:`Now (fun () -> Reader.file_contents [%string "%{path}/%{internal.path}"]) with
      | Error _ | Ok "" -> return ()
      | Ok data ->
        let data = Yaml.of_string data |> Info.t_of_yaml in
        internal.prev_info <- data;
        return ()
    ;;

    let patch : t Spec.t =
      Spec.conv (fun json ->
          let key = P.key json in
          match String.Map.find internal.prev_info.manual key with
          | Some data ->
            internal.next_info.manual <- String.Map.set internal.next_info.manual ~key ~data;
            P.lookup data |> Option.value ~default:P.default
          | None ->
            (match
               try Spec.resolve P.accessor json with
               | _ -> None
             with
            | Some t -> t
            | None ->
              (match String.Map.find internal.prev_info.computed key with
              | Some data ->
                internal.next_info.computed <- String.Map.set internal.next_info.computed ~key ~data;
                Option.bind data ~f:P.lookup |> Option.value ~default:P.default
              | None ->
                internal.next_info.computed <- String.Map.set internal.next_info.computed ~key ~data:None;
                P.default)))
    ;;

    let forget json =
      let key = P.key json in
      internal.next_info.computed <- String.Map.remove internal.next_info.computed key
    ;;

    let save path =
      String.Map.to_alist internal.next_info.computed
      |> List.filter_map ~f:(fun (key, data) ->
             match data with
             | Some _ -> None
             | None -> Some key)
      |> List.iter ~f:(fun missing -> eprintf "%s\n" [%string "missing patch: %{missing}"]);
      let contents = Info.yaml_of_t internal.next_info |> Yaml.to_string in
      Writer.save [%string "%{path}/%{internal.path}"] ~contents
    ;;
  end

  include T
  module Erased = T
end

let source_patcher name : (module S with type t = Source.t) =
  (module Make (struct
    type t = Source.t

    let name = name
    let kind = "source"
    let default = Source.missing

    let key = function
      | `Assoc t ->
        let json = List.find_exn t ~f:(fun (name, _) -> String.equal name "name") |> snd in
        (match json with
        | `String name -> name
        | t -> raise_s [%message "Failure to parse key" (t : Json.t)])
      | t -> raise_s [%message "Failure to parse key" (t : Json.t)]
    ;;

    let accessor =
      let%map_open.Spec source = data / "source" >> string in
      Source.normalize source
    ;;

    let lookup abbr = Source.find ~abbr
  end))
;;
