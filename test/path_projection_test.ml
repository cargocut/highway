(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(* A set of tests relating to the conversion of a Path to a list of
   strings. *)

open struct
  open Alcotest

  let projection_1 =
    test_case "Project an empty URL" `Quick (fun () ->
      let path =
        let open Highway.Path in
        []
      in
      let expected = []
      and computed = Highway.Path.to_list path [] in
      check (list string) "should be equal" expected computed)
  ;;

  let projection_2 =
    test_case "Project an URL without arguments" `Quick (fun () ->
      let path =
        let open Highway in
        let open Path in
        Pattern.[ s "foo"; s "bar"; s "baz" ]
      in
      let expected = [ "foo"; "bar"; "baz" ]
      and computed = Highway.Path.to_list path [] in
      check (list string) "should be equal" expected computed)
  ;;

  let projection_3 =
    test_case "Project an URL with some arguments" `Quick (fun () ->
      let path =
        let open Highway in
        let open Path in
        Pattern.[ s "foo"; string; s "baz"; int ]
      in
      let expected = [ "foo"; "bar"; "baz"; "42" ]
      and computed = Highway.Path.to_list path [ "bar"; 42 ] in
      check (list string) "should be equal" expected computed)
  ;;

  let projection_4 =
    test_case "Project an URL with a lot of arguments" `Quick (fun () ->
      let path =
        let open Highway in
        let open Path in
        Pattern.[ s "foo"; string; s "baz"; int; bool; char; float; string ]
      in
      let expected = [ "foo"; "bar"; "baz"; "42"; "true"; "c"; "3.14"; "fin" ]
      and computed =
        Highway.Path.to_list path [ "bar"; 42; true; 'c'; 3.14; "fin" ]
      in
      check (list string) "should be equal" expected computed)
  ;;

  module Positive_int : sig
    type t = private int

    val mk : int -> t
    val pattern : (t -> 'a, 'a) Highway.Pattern.t
  end = struct
    type t = int

    let mk x = if x < 0 then failwith "[mk] negative x" else x
    let hole = Highway.Hole.(invmap Fun.id Fun.id int)
    let pattern = Highway.Pattern.Hole hole
  end

  let projection_5 =
    test_case
      "Project an URL with a lot of arguments and catenation"
      `Quick
      (fun () ->
         let path =
           let open Highway in
           let open Path in
           let open Pattern in
           [ s "foo"; string; s "baz" ]
           ++ [ int; bool; char; float; string; s "foobar" ]
           ++ [ int; int; int; Positive_int.pattern ]
         in
         let expected =
           [ "foo"
           ; "bar"
           ; "baz"
           ; "42"
           ; "true"
           ; "c"
           ; "3.14"
           ; "fin"
           ; "foobar"
           ; "1"
           ; "2"
           ; "3"
           ; "4"
           ]
         and computed =
           Highway.Path.to_list
             path
             [ "bar"; 42; true; 'c'; 3.14; "fin"; 1; 2; 3; Positive_int.mk 4 ]
         in
         check (list string) "should be equal" expected computed)
  ;;

  let projection_6 =
    test_case
      "Project an URL with a lot of arguments and catenation"
      `Quick
      (fun () ->
         let path =
           let open Highway in
           let open Path in
           let open Pattern in
           [ s "foo bar"; string; s "baz" ]
           ++ [ int; bool; char; float; string; s "foobar" ]
           ++ [ int; int; int; Positive_int.pattern ]
         in
         let expected =
           [ "foo%20bar"
           ; "bar"
           ; "baz"
           ; "42"
           ; "true"
           ; "c"
           ; "3.14"
           ; "fin%20du%20monde"
           ; "foobar"
           ; "1"
           ; "2"
           ; "3"
           ; "4"
           ]
         and computed =
           Highway.Path.to_list
             path
             [ "bar"
             ; 42
             ; true
             ; 'c'
             ; 3.14
             ; "fin du monde"
             ; 1
             ; 2
             ; 3
             ; Positive_int.mk 4
             ]
         in
         check (list string) "should be equal" expected computed)
  ;;
end

let cases =
  ( "Path Projection"
  , [ projection_1
    ; projection_2
    ; projection_3
    ; projection_4
    ; projection_5
    ; projection_6
    ] )
;;
