(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

open struct
  open Alcotest

  let encode1 =
    test_case "encode" `Quick (fun () ->
      let input = "" in
      let expected = ""
      and computed = Highway.Pct.(encode ~is_allowed:is_path_segment) input in
      check string "should be equal" expected computed)
  ;;

  let encode2 =
    test_case "encode" `Quick (fun () ->
      let input = "foobar" in
      let expected = "foobar"
      and computed = Highway.Pct.(encode ~is_allowed:is_path_segment) input in
      check string "should be equal" expected computed)
  ;;

  let encode3 =
    test_case "encode" `Quick (fun () ->
      let input = "Hello World, café" in
      let expected = "Hello%20World,%20caf%C3%A9"
      and computed = Highway.Pct.(encode ~is_allowed:is_path_segment) input in
      check string "should be equal" expected computed)
  ;;

  let encode4 =
    test_case "encode" `Quick (fun () ->
      let input = "Hello Günter" in
      let expected = "Hello%20G%C3%BCnter"
      and computed = Highway.Pct.(encode ~is_allowed:is_path_segment) input in
      check string "should be equal" expected computed)
  ;;

  let encode5 =
    test_case "encode" `Quick (fun () ->
      let input = "Hello Günter" in
      let expected = "Hello+G%C3%BCnter"
      and computed = Highway.Pct.(encode ~is_allowed:is_path_segment) input in
      check string "should be equal" expected computed)
  ;;

  let encode6 =
    test_case "encode" `Quick (fun () ->
      let input = "Hello Günter+" in
      let expected = "Hello+G%C3%BCnter%2B"
      and computed = Highway.Pct.(encode ~is_allowed:is_path_segment) input in
      check string "should be equal" expected computed)
  ;;

  let decode1 =
    test_case "decode" `Quick (fun () ->
      let input = "" in
      let expected = ""
      and computed = Highway.Pct.decode input in
      check string "should be equal" expected computed)
  ;;

  let decode2 =
    test_case "decode" `Quick (fun () ->
      let input = "foobar" in
      let expected = "foobar"
      and computed = Highway.Pct.decode input in
      check string "should be equal" expected computed)
  ;;

  let decode3 =
    test_case "decode" `Quick (fun () ->
      let input = "foo bar" in
      let expected = "foo bar"
      and computed = Highway.Pct.decode input in
      check string "should be equal" expected computed)
  ;;

  let decode4 =
    test_case "decode" `Quick (fun () ->
      let input = "foo%20bar" in
      let expected = "foo bar"
      and computed = Highway.Pct.decode input in
      check string "should be equal" expected computed)
  ;;

  let decode5 =
    test_case "decode" `Quick (fun () ->
      let input = "Hello%20G%C3%BCnter" in
      let expected = "Hello Günter"
      and computed = Highway.Pct.decode input in
      check string "should be equal" expected computed)
  ;;

  let decode6 =
    test_case "decode" `Quick (fun () ->
      let input = "Hello+G%C3%BCnter%2B+" in
      let expected = "Hello Günter+ "
      and computed = Highway.Pct.decode ~plus_as_space:true input in
      check string "should be equal" expected computed)
  ;;
end

let cases =
  ( "Pct"
  , [ encode1
    ; encode2
    ; encode3
    ; encode4
    ; encode5
    ; encode6
    ; decode1
    ; decode2
    ; decode3
    ; decode4
    ; decode5
    ; decode6
    ] )
;;
