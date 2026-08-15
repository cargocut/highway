(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(* Yet Another Real World Example. *)

module Param = struct
  include Highway.Param

  type pagination =
    { page : int
    ; size : int
    }

  let make_pagination ?(page = 0) ?(size = 10) () = { page; size }

  let lang =
    define
      ~from_query:(fun fields -> Pidgin.Check.(opt fields "lang" string))
      ~to_query:(function
        | None -> []
        | Some lang -> [ "lang", lang ])
  ;;

  let pagination =
    define
      ~from_query:(fun fields ->
        let open Pidgin.Check in
        let+ page = opt fields "page" (int & Int.is_positive)
        and+ size = opt fields "size" (int & Int.is_positive) in
        make_pagination ?page ?size ())
      ~to_query:(fun { page; size } ->
        [ "page", string_of_int page; "size", string_of_int size ])
  ;;

  let string key = from_hole Highway.Hole.string ~key
  let string' key = from_opt_hole Highway.Hole.string ~key
  let bool key = from_hole Highway.Hole.bool ~key
  let bool' key = from_opt_hole Highway.Hole.bool ~key
  let all = lang & pagination
end

type operator =
  | Add
  | Sub
  | Mul

let operator () =
  (* Geez, it is sad to have this unit things. *)
  let hole =
    Highway.Hole.make
      ~to_string:(function
        | Add -> "+"
        | Sub -> "-"
        | Mul -> "*")
      ~from_string:(function
        | "+" -> Some Add
        | "-" -> Some Sub
        | "*" -> Some Mul
        | _ -> None)
  in
  Highway.Pattern.Hole hole
;;

module Routes = struct
  open Highway.Route
  open Highway.Pattern

  let home = get [] Param.nop
  let hello = get [ s "hello" ] (Param.string' "username")
  let arith = post [ s "arith"; operator (); int; int ] (Param.bool' "negative")
end

open struct end

let cases = "Real World Example", []
