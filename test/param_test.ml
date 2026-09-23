(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

open struct
  let pp render_param ppf x =
    let open Format in
    fprintf
      ppf
      "%a"
      (pp_print_list
         ~pp_sep:(fun ppf () -> fprintf ppf "&")
         (fun ppf (k, v) -> fprintf ppf "@[%s=%s@]" k v))
      (render_param x)
  ;;

  module Desc = struct
    type t =
      { title : string
      ; length : int
      ; chars : char list
      ; aliases : string list
      }

    let make ?(chars = []) ?(aliases = []) ~title ~length () =
      { title; length; chars; aliases }
    ;;

    let check_param fields =
      let open Pidgin.Check in
      let+ title = req fields "title" string
      and+ length = req fields "length" int
      and+ chars = opt fields "chars" (list_of char / (char $ fun x -> [ x ]))
      and+ aliases =
        opt fields "aliases" (list_of string / (string $ fun x -> [ x ]))
      in
      make ~title ~length ?chars ?aliases ()
    ;;

    let render_param { title; length; chars; aliases } =
      [ "title", title; "length", string_of_int length ]
      @ List.map (fun v -> "chars", String.make 1 v) chars
      @ List.map (fun v -> "aliases", v) aliases
    ;;

    let pp = pp render_param

    let equal { title; length; chars; aliases } b =
      String.equal title b.title
      && Int.equal length b.length
      && List.equal Char.equal chars b.chars
      && List.equal String.equal aliases b.aliases
    ;;

    let testable = Alcotest.testable pp equal
  end

  module Pagination = struct
    type t =
      { page : int
      ; size : int
      }

    let make ?(page = 1) ~size () = { page; size }
    let equal { page; size } b = Int.equal page b.page && Int.equal size b.size

    let check_param fields =
      let open Pidgin.Check in
      let+ page = opt fields "page" int
      and+ size = req fields "size" int in
      make ?page ~size ()
    ;;

    let render_param { page; size } =
      [ "page", string_of_int page; "size", string_of_int size ]
    ;;

    let pp = pp render_param
    let testable = Alcotest.testable pp equal
  end

  let desc = Highway.Param.make (module Desc)
  let pagination = Highway.Param.make (module Pagination)
  let with_page = Highway.Param.(desc & pagination)

  open Alcotest

  let to_query_string1 =
    test_case "to_query_string" `Quick (fun () ->
      let subject = Desc.make ~title:"title" ~length:10 () in
      let expected = Some "title=title&length=10"
      and computed = Highway.Param.to_query_string desc subject in
      check (option string) "should be equal" expected computed)
  ;;

  let to_query_string2 =
    test_case "to_query_string" `Quick (fun () ->
      let subject =
        Desc.make
          ~chars:[ 'a'; 'b'; 'c' ]
          ~aliases:[ "foo"; "bar"; "baz" ]
          ~title:"title"
          ~length:10
          ()
      in
      let expected =
        Some
          "title=title&length=10&chars=a&chars=b&chars=c&aliases=foo&aliases=bar&aliases=baz"
      and computed = Highway.Param.to_query_string desc subject in
      check (option string) "should be equal" expected computed)
  ;;

  let to_query_string3 =
    test_case "to_query_string" `Quick (fun () ->
      let subject = () in
      let expected = None
      and computed = Highway.Param.to_query_string Highway.Param.nop subject in
      check (option string) "should be equal" expected computed)
  ;;

  let to_query_string4 =
    test_case "to_query_string" `Quick (fun () ->
      let subject = () in
      let expected = None
      and computed = Highway.Param.to_query_string Highway.Param.lax subject in
      check (option string) "should be equal" expected computed)
  ;;

  let to_query_string5 =
    test_case "to_query_string" `Quick (fun () ->
      let subject =
        Desc.make ~title:"title" ~length:10 (), Pagination.make ~size:10 ()
      in
      let expected = Some "title=title&length=10&page=1&size=10"
      and computed = Highway.Param.to_query_string with_page subject in
      check (option string) "should be equal" expected computed)
  ;;

  let from_query1 =
    test_case "from_query" `Quick (fun () ->
      let subject = [ "title", "foo"; "length", "43" ] in
      let expected = Some (Desc.make ~title:"foo" ~length:43 ())
      and computed = Highway.Param.from_query desc subject in
      check (option Desc.testable) "should be equal" expected computed)
  ;;

  let from_query2 =
    test_case "from_query" `Quick (fun () ->
      let subject =
        [ "title", "foo"
        ; "length", "43"
        ; "chars", "a"
        ; "chars", "Z"
        ; "aliases", "xvw"
        ]
      in
      let expected =
        Some
          (Desc.make
             ~title:"foo"
             ~length:43
             ~chars:[ 'a'; 'Z' ]
             ~aliases:[ "xvw" ]
             ())
      and computed = Highway.Param.from_query desc subject in
      check (option Desc.testable) "should be equal" expected computed)
  ;;

  let from_query3 =
    test_case "from_query" `Quick (fun () ->
      let subject =
        [ "title", "foo"
        ; "length", "43"
        ; "chars", "a"
        ; "chars", "Z"
        ; "aliases", "xvw"
        ; "aliases", "xvw2"
        ]
      in
      let expected =
        Some
          (Desc.make
             ~title:"foo"
             ~length:43
             ~chars:[ 'a'; 'Z' ]
             ~aliases:[ "xvw"; "xvw2" ]
             ())
      and computed = Highway.Param.from_query desc subject in
      check (option Desc.testable) "should be equal" expected computed)
  ;;

  let from_query4 =
    test_case "from_query" `Quick (fun () ->
      let subject =
        [ "title", "foo"
        ; "chars", "a"
        ; "chars", "Z"
        ; "aliases", "xvw"
        ; "aliases", "xvw2"
        ]
      in
      let expected = None
      and computed = Highway.Param.from_query desc subject in
      check (option Desc.testable) "should be equal" expected computed)
  ;;

  let from_query5 =
    test_case "from_query" `Quick (fun () ->
      let subject =
        [ "title", "foo"
        ; "chars", "a"
        ; "chars", "Z"
        ; "aliases", "xvw"
        ; "aliases", "xvw2"
        ]
      in
      let expected = None
      and computed = Highway.Param.from_query Highway.Param.nop subject in
      check (option unit) "should be equal" expected computed)
  ;;

  let from_query6 =
    test_case "from_query" `Quick (fun () ->
      let subject = [] in
      let expected = Some ()
      and computed = Highway.Param.from_query Highway.Param.nop subject in
      check (option unit) "should be equal" expected computed)
  ;;

  let from_query7 =
    test_case "from_query" `Quick (fun () ->
      let subject =
        [ "title", "foo"
        ; "length", "43"
        ; "page", "23"
        ; "chars", "a"
        ; "chars", "Z"
        ; "aliases", "xvw"
        ; "aliases", "xvw2"
        ; "size", "22334"
        ]
      in
      let expected =
        Some
          ( Desc.make
              ~title:"foo"
              ~length:43
              ~chars:[ 'a'; 'Z' ]
              ~aliases:[ "xvw"; "xvw2" ]
              ()
          , Pagination.make ~page:23 ~size:22334 () )
      and computed = Highway.Param.from_query with_page subject in
      check
        (option (pair Desc.testable Pagination.testable))
        "should be equal"
        expected
        computed)
  ;;

  let from_query8 =
    test_case "from_query" `Quick (fun () ->
      let subject = [] in
      let expected = Some ()
      and computed = Highway.Param.from_query Highway.Param.lax subject in
      check (option unit) "should be equal" expected computed)
  ;;

  let from_query9 =
    test_case "from_query" `Quick (fun () ->
      let subject = [ "test", "true" ] in
      let expected = Some true
      and computed =
        Highway.Param.from_query
          Highway.Param.(from_hole ~key:"test" Highway.Hole.bool)
          subject
      in
      check (option bool) "should be equal" expected computed)
  ;;

  let from_query10 =
    test_case "from_query" `Quick (fun () ->
      let subject = [ "test", "false" ] in
      let expected = Some (Some false)
      and computed =
        Highway.Param.from_query
          Highway.Param.(from_opt_hole ~key:"test" Highway.Hole.bool)
          subject
      in
      check (option @@ option bool) "should be equal" expected computed)
  ;;

  let from_query11 =
    test_case "from_query" `Quick (fun () ->
      let subject =
        [ "title", "foo+bar+baz"
        ; "length", "43"
        ; "chars", "a"
        ; "chars", "Z"
        ; "aliases", "xvw"
        ; "aliases", "xvw2%20grm"
        ]
      in
      let expected =
        Some
          (Desc.make
             ~title:"foo bar baz"
             ~length:43
             ~chars:[ 'a'; 'Z' ]
             ~aliases:[ "xvw"; "xvw2 grm" ]
             ())
      and computed = Highway.Param.from_query ~decode:true desc subject in
      check (option Desc.testable) "should be equal" expected computed)
  ;;
end

let cases =
  ( "Param"
  , [ to_query_string1
    ; to_query_string2
    ; to_query_string3
    ; to_query_string4
    ; to_query_string5
    ; from_query1
    ; from_query2
    ; from_query3
    ; from_query4
    ; from_query5
    ; from_query6
    ; from_query7
    ; from_query8
    ; from_query9
    ; from_query10
    ; from_query11
    ] )
;;
