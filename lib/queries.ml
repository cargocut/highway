(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type nested_list = (string * string list) list
type flat_list = (string * string) list

module M = Map.Make (String)

let translate_string s =
  let open Pidgin.Repr in
  match int_of_string_opt s with
  | Some i -> int i
  | None ->
    (match float_of_string_opt s with
     | Some f -> float f
     | None ->
       (* KLUDGE: It's a bit of an over-the-top hack that lets
          you... pass records directly into query parameters... *)
       (match
          s
          |> Pidgin.Csexp.from_string
          |> Result.map Pidgin.Csexp.translate_to_pidgin
        with
        | Ok r -> r
        | Error _ -> string s))
;;

let is_kwd x y = String.equal (Pidgin.Misc.strim x) y

let to_pidgin =
  let open Pidgin.Repr in
  function
  | s when is_kwd s "null" -> null ()
  | s when is_kwd s "true" -> bool true
  | s when is_kwd s "false" -> bool false
  | s -> translate_string s
;;

let to_pidgin_list = function
  | [ x ] -> to_pidgin x
  | xs -> Pidgin.Repr.list_of to_pidgin xs
;;

let to_nested_list list =
  let map =
    list
    |> List.fold_left
         (fun m (k, v) ->
            M.update
              k
              (function
                | None -> Some [ v ]
                | Some acc -> Some (v :: acc))
              m)
         M.empty
  in
  M.fold (fun k v acc -> (k, List.rev v) :: acc) map []
;;

module Nested = struct
  type t = nested_list

  open Pidgin.Repr

  let translate_to_pidgin l =
    record (List.map (fun (k, v) -> k, to_pidgin_list v) l)
  ;;

  let from_pidgin = function
    | Null -> "null"
    | Bool true -> "true"
    | Bool false -> "false"
    | Int x -> string_of_int x
    | Float x -> string_of_float x
    | String s -> s
    | (List _ | Record _) as other ->
      (* KLUDGE: We cheat for the same reason into [to_pidgin]. *)
      other |> Pidgin.Csexp.translate_from_pidgin |> Pidgin.Csexp.to_string
  ;;

  let translate_from_pidgin = function
    | Record xs ->
      List.map
        (fun (k, v) ->
           match v with
           | List xs ->
             (* KLUDGE: Another dirty hack for dealing with top-level lists *)
             k, List.map from_pidgin xs
           | v -> k, [ from_pidgin v ])
        xs
    (* KLUDGE: hard to find a better case here. *)
    | List xs -> [ "arg", List.map from_pidgin xs ]
    | other -> [ "arg", [ from_pidgin other ] ]
  ;;
end

module Flat = struct
  type t = flat_list

  let translate_to_pidgin l = l |> to_nested_list |> Nested.translate_to_pidgin

  let translate_from_pidgin repr =
    repr
    |> Nested.translate_from_pidgin
    |> List.fold_left (fun acc (k, xs) -> acc @ List.map (fun v -> k, v) xs) []
  ;;
end

type 'a t =
  { to_pidgin : 'a Pidgin.Repr.conv
  ; from_pidgin : 'a Pidgin.Check.t
  }

let to_query_params device value =
  Option.bind device (fun { to_pidgin; _ } ->
    value
    |> to_pidgin
    |> Flat.translate_from_pidgin
    |> function
    | [] -> None
    | xs -> Some xs)
;;

let to_query_string device value =
  Option.map
    (fun xs ->
       "?" ^ (xs |> List.map (fun (k, v) -> k ^ "=" ^ v) |> String.concat "&"))
    (to_query_params device value)
;;

let check_query_params device value =
  match device with
  | None -> Ok None
  | Some { from_pidgin; _ } ->
    value
    |> Flat.translate_to_pidgin
    |> from_pidgin
    |> (function
     | Ok x -> Ok (Some x)
     | Error _ -> Error ())
;;
