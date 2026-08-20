(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

open struct
  open Alcotest

  let from_nested_list1 =
    test_case "From nested list" `Quick (fun () ->
      let expected = []
      and computed = Highway.Param.from_nested_list [] in
      check (list (pair string string)) "should be equal" expected computed)
  ;;

  let from_nested_list2 =
    test_case "From nested list" `Quick (fun () ->
      let expected = [ "bar", "1"; "bar", "2"; "bar", "3"; "foobar", "foo" ]
      and computed =
        Highway.Param.from_nested_list
          [ "foo", []; "bar", [ "1"; "2"; "3" ]; "foobar", [ "foo" ] ]
      in
      check (list (pair string string)) "should be equal" expected computed)
  ;;
end

let cases = "Nested List conversion", [ from_nested_list1; from_nested_list2 ]
