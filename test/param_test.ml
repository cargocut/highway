(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

open struct
  type a =
    { title : string
    ; length : int
    ; chars : char list
    ; aliases : string list
    }

  type pagination =
    { page : int
    ; size : int
    }

  let make_a ?(chars = []) ?(aliases = []) ~title ~length () =
    { title; length; chars; aliases }
  ;;

  let make_pagination ?(page = 1) ~size () = { page; size }

  let a =
    Highway.Param.define
      ~from_query:(fun fields ->
        let open Pidgin.Check in
        let+ title = req fields "title" string
        and+ length = req fields "length" int
        and+ chars = opt fields "chars" (list_of char)
        and+ aliases = opt fields "aliases" (list_of string) in
        make_a ~title ~length ?chars ?aliases ())
      ~to_query:(fun { title; length; chars; aliases } ->
        [ "title", title; "length", string_of_int length ]
        @ List.map (fun v -> "chars", String.make 1 v) chars
        @ List.map (fun v -> "aliases", v) aliases)
  ;;

  let pagination =
    Highway.Param.define
      ~from_query:(fun fields ->
        let open Pidgin.Check in
        let+ page = opt fields "page" int
        and+ size = req fields "size" int in
        make_pagination ?page ~size ())
      ~to_query:(fun { page; size } ->
        [ "page", string_of_int page; "size", string_of_int size ])
  ;;

  let a_with_page = Highway.Param.(a & pagination)
end

let cases = "Param", []
