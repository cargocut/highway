(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type ('request, 'query_params) t = 'request -> ('query_params, unit) result
type nested_list = (string * string list) list
type flatten_list = (string * string) list

let nop _ = Ok ()

module Pidigin_helpers = struct
  let is_kwd x y = String.equal (Pidgin.Misc.strim x) y

  let translate_string s =
    let open Pidgin.Repr in
    match int_of_string_opt s with
    | Some i -> int i
    | None ->
      (match float_of_string_opt s with
       | Some f -> float f
       | None -> string s)
  ;;

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

  let from_list list =
    Pidgin.Repr.record (List.map (fun (k, v) -> k, to_pidgin_list v) list)
  ;;

  module M = Map.Make (String)

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
end

let from_nested_list check list =
  list
  |> Pidigin_helpers.from_list
  |> check
  |> function
  | Ok x -> Ok x
  | Error _ -> Error ()
;;

let from_flatten_list check list =
  list |> Pidigin_helpers.to_nested_list |> from_nested_list check
;;

let extract_from_nested get_qp check request =
  request |> get_qp |> from_nested_list check
;;

let extract_from_flatten get_qp check request =
  request |> get_qp |> from_flatten_list check
;;

let extract = extract_from_flatten
