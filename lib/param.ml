(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type 'a device =
  { from_query : (string * Pidgin.Repr.t) list -> 'a Pidgin.Check.record
  ; to_query : 'a -> (string * string) list
  }

let device ~from_query ~to_query = { from_query; to_query }

type nothing = private Nothing
type something = private Something

type ('constraints, 'ty) t =
  | Nothing : (nothing, unit) t
  | Something : 'a device -> (something, 'a) t

let invmap (Something a) from_a to_a =
  let from_query x = x |> a.from_query |> Result.map from_a
  and to_query x = x |> to_a |> a.to_query in
  Something { from_query; to_query }
;;

module Infix = struct
  let ( & ) (Something a) (Something b) =
    let from_query fields =
      let open Pidgin.Check in
      let+ a = use_record fields (record a.from_query)
      and+ b = use_record fields (record b.from_query) in
      a, b
    and to_query (x, y) = a.to_query x @ b.to_query y in
    Something { from_query; to_query }
  ;;

  let ( / ) (Something a) (Something b) =
    let from_query fields =
      let open Pidgin.Check in
      use_record
        fields
        ((record a.from_query $ Either.left)
         / (record b.from_query $ Either.right))
    and to_query = function
      | Either.Left x -> a.to_query x
      | Either.Right x -> b.to_query x
    in
    Something { from_query; to_query }
  ;;
end

include Infix

let nop = Nothing
let define ~from_query ~to_query = Something (device ~from_query ~to_query)
let lax = define ~from_query:(fun _ -> Ok ()) ~to_query:(fun () -> [])

let make (type a) (module T : Sigs.AS_PARAM with type t = a) =
  define ~from_query:T.check_param ~to_query:T.render_param
;;

module M = Map.Make (String)

type one_or_more =
  | One of string
  | More of string list

let kwd_equal value kwd =
  String.equal (Pidgin.Misc.strim value) (Pidgin.Misc.strim kwd)
;;

let string_to_pidgin x =
  match int_of_string_opt x with
  | Some i -> Pidgin.Repr.int i
  | None ->
    (match float_of_string_opt x with
     | Some f -> Pidgin.Repr.float f
     | None -> Pidgin.Repr.string x)
;;

let to_pidgin_str = function
  | s when kwd_equal s "true" -> Pidgin.Repr.bool true
  | s when kwd_equal s "false" -> Pidgin.Repr.bool false
  | s -> string_to_pidgin s
;;

let to_pidgin list =
  (* NOTE: The purpose of this function is to provide a reasonable
     representation of query parameters as a [string * string] list in
     Pidgin representation. *)
  M.fold
    (fun key value acc ->
       match value with
       | [] -> acc
       | [ one ] -> (key, One one) :: acc
       | xs -> (key, More xs) :: acc)
    (List.fold_left
       (fun map (k, v) ->
          M.update
            k
            (function
              | None -> Some [ v ]
              | Some xs -> Some (v :: xs))
            map)
       M.empty
       list)
    []
  |> List.map (fun (k, v) ->
    ( k
    , match v with
      | One s -> to_pidgin_str s
      | More xs -> Pidgin.Repr.list_of to_pidgin_str (List.rev xs) ))
  |> function
  | [] -> Pidgin.Repr.null ()
  | xs -> Pidgin.Repr.record xs
;;

let from_query : type cstr a. (cstr, a) t -> (string * string) list -> a option =
  fun device params ->
  match device, params with
  | Nothing, [] -> Some ()
  | Nothing, _ -> None
  | Something { from_query; _ }, xs ->
    let pidgin = to_pidgin xs in
    Pidgin.Check.record from_query pidgin |> Result.to_option
;;

let to_query_params : type cstr a. (cstr, a) t -> a -> (string * string) list =
  fun device subject ->
  match device with
  | Nothing -> []
  | Something { to_query; _ } -> to_query subject
;;

let to_query_string : type cstr a. (cstr, a) t -> a -> string option =
  fun device subject ->
  match to_query_params device subject with
  | [] -> None
  | (k, v) :: xs ->
    Some
      (List.fold_left
         (fun result (k, v) -> result ^ "&" ^ k ^ "=" ^ v)
         (k ^ "=" ^ v)
         xs)
;;
