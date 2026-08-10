(* Copyright (c) 2026, Cargocut and the Lunar developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(* A set of tests relating to the interpretation of Path as a list of
   arguments. *)

open struct
  open Alcotest

  let handling_1 =
    test_case "With empty path and empty pattern" `Quick (fun () ->
      let path =
        let open Highway.Path in
        []
      and input = List.[] in
      match Highway.Path.from_list path input with
      | None -> fail "The path should be valid"
      | Some [] -> ())
  ;;

  let handling_2 =
    test_case "With non-empty path and empty pattern" `Quick (fun () ->
      let path =
        let open Highway.Path in
        []
      and input = List.[ "foo"; "bar"; "baz" ] in
      match Highway.Path.from_list path input with
      | None -> ()
      | Some [] -> fail "The path should not be valid")
  ;;

  let handling_3 =
    test_case "Complicated pattern" `Quick (fun () ->
      let path =
        let open Highway in
        let open Path in
        [ s "foo"; string; s "baz" ]
        ++ [ int; bool; char; float; string; s "foobar" ]
        ++ [ int; int; int ]
      and input =
        List.
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
          ]
      in
      match Highway.Path.from_list path input with
      | Some [ "bar"; 42; true; 'c'; 3.14; "fin"; 1; 2; 3 ] -> ()
      | _ -> fail "Invalid Path")
  ;;
end

let cases = "Path Handling", [ handling_1; handling_2; handling_3 ]
