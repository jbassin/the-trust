open! Core
open! Async
open! Import
open! Patcher_intf

module Info = struct
  type t =
    { mutable computed : string option String.Map.t
    ; mutable manual : string String.Map.t
    }
  [@@deriving sexp]

  let empty = { computed = String.Map.empty; manual = String.Map.empty }
end

module Make (P : P) : S = struct
  type t = P.t

  type internal =
    { path : string
    ; mutable prev_info : Info.t
    ; next_info : Info.t
    }

  let internal =
    let path = [%string "%{P.name}-%{P.kind}.sexp"] in
    { path; prev_info = Info.empty; next_info = Info.empty }
  ;;

  let init path =
    match%bind Reader.file_contents [%string "%{path}/%{internal.path}"] with
    | "" -> return ()
    | data ->
      let data = Sexp.of_string data |> [%of_sexp: Info.t] in
      internal.prev_info <- data;
      return ()
  ;;

  let patch json =
    let key = P.key json in
    match String.Map.find internal.prev_info.manual key with
    | Some data ->
      internal.next_info.manual <- String.Map.set internal.next_info.manual ~key ~data;
      P.lookup data |> Option.value ~default:P.default
    | None ->
      (match P.accessor json with
      | Some t -> t
      | None ->
        (match String.Map.find internal.prev_info.computed key with
        | Some data ->
          internal.next_info.computed
            <- String.Map.set internal.next_info.computed ~key ~data;
          Option.bind data ~f:P.lookup |> Option.value ~default:P.default
        | None -> P.default))
  ;;

  let forget json =
    let key = P.key json in
    internal.next_info.computed <- String.Map.remove internal.next_info.computed key
  ;;

  let save path =
    Writer.save_sexp
      [%string "%{path}/%{internal.path}"]
      ([%sexp_of: Info.t] internal.next_info)
  ;;
end
