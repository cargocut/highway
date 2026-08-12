(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(* A Real World Example. *)

open struct
  open Highway

  let error code _req = "Error " ^ string_of_int code
  let user_rejected handler req = if !req then error 401 req else handler () req
  let need_user handler req = if !req then handler "xvw" req else error 401 req

  module Routes = struct
    let home = get []
    let hello_auth = get [ s "hello" ]
    let hello = get [ s "hello"; string ]
    let login = post [ s "login"; int ]
    let logout = post [ s "logout" ]
  end

  module Services = struct
    let home =
      service
        ~extractor:no_extraction
        ~context:unit
        ~route:Routes.home
        (fun [] () () _req -> "Welcome to The home of my website")
    ;;

    let hello_auth =
      service
        ~extractor:no_extraction
        ~context:need_user
        ~route:Routes.hello_auth
        (fun [] () username _req -> "Welcome authorized user, " ^ username)
    ;;

    let hello =
      service
        ~extractor:no_extraction
        ~context:unit
        ~route:Routes.hello
        (fun [ name ] () () _req -> "Hello, " ^ name)
    ;;

    let login =
      service
        ~extractor:no_extraction
        ~context:user_rejected
        ~route:Routes.login
        (fun [ code ] () () req ->
           if Int.equal code 12345678
           then (
             req := true;
             "You are connected")
           else error 401 req)
    ;;

    let logout =
      service
        ~extractor:no_extraction
        ~context:need_user
        ~route:Routes.logout
        (fun [] () username req ->
           req := false;
           "Bye bye " ^ username)
    ;;

    let dispatch given_method given_path =
      dispatch
        ~given_method
        ~given_path
        [ home; hello_auth; hello; login; logout ]
        (error 404)
    ;;
  end

  open Alcotest

  let error_404_test =
    test_case "produce a 404 error" `Quick (fun () ->
      let request = ref false in
      let expected = "Error 404"
      and computed = Services.dispatch `PUT [] request in
      check string "should be equal" expected computed)
  ;;

  let home_test =
    test_case "get the Home" `Quick (fun () ->
      let request = ref false in
      let expected = "Welcome to The home of my website"
      and computed = Services.dispatch `GET [] request in
      check string "should be equal" expected computed)
  ;;

  let say_hello_test =
    test_case "get the hello" `Quick (fun () ->
      let request = ref false in
      let expected = "Hello, WORLD"
      and computed = Services.dispatch `GET [ "hello"; "WORLD" ] request in
      check string "should be equal" expected computed)
  ;;

  let say_auth_hello_test =
    test_case "get the auth hello page" `Quick (fun () ->
      let request = ref true in
      let expected = "Welcome authorized user, xvw"
      and computed = Services.dispatch `GET [ "hello" ] request in
      check string "should be equal" expected computed)
  ;;

  let auth_when_already_auth_test =
    test_case "auth when already auth" `Quick (fun () ->
      let request = ref true in
      let expected = "Error 401"
      and computed = Services.dispatch `POST [ "login"; "12345" ] request in
      check string "should be equal" expected computed)
  ;;

  let auth_when_not_auth_test =
    test_case "auth when not auth" `Quick (fun () ->
      let request = ref false in
      let expected = "You are connected"
      and computed = Services.dispatch `POST [ "login"; "12345678" ] request in
      check string "should be equal" expected computed)
  ;;

  let auth_when_not_auth_pass_failed_test =
    test_case "auth when not auth (with wrong password)" `Quick (fun () ->
      let request = ref false in
      let expected = "Error 401"
      and computed = Services.dispatch `POST [ "login"; "12345" ] request in
      check string "should be equal" expected computed)
  ;;

  let logout_when_not_auth_test =
    test_case "logout when not auth" `Quick (fun () ->
      let request = ref false in
      let expected = "Error 401"
      and computed = Services.dispatch `POST [ "logout" ] request in
      check string "should be equal" expected computed)
  ;;

  let logout_when_auth_test =
    test_case "logout when  auth" `Quick (fun () ->
      let request = ref true in
      let expected = "Bye bye xvw"
      and computed = Services.dispatch `POST [ "logout" ] request in
      check string "should be equal" expected computed)
  ;;
end

let cases =
  ( "Router"
  , [ error_404_test
    ; home_test
    ; say_hello_test
    ; say_auth_hello_test
    ; auth_when_already_auth_test
    ; auth_when_not_auth_test
    ; logout_when_not_auth_test
    ; logout_when_auth_test
    ; auth_when_not_auth_pass_failed_test
    ] )
;;
