(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(* A set of tests relating to the link generation for routes. *)

open struct
  open Alcotest

  (* KLUDGE: Here, we should wrap the routes in `unit` functions;
     otherwise, they are immediately unified as soon as they are
     used. But we're only trying to describe the serialization
     involved, so... *)

  let p1 =
    let open Highway in
    get [ s "user"; string; s "age"; int ]
  ;;

  let p2 =
    let open Highway in
    global "https://xvw.lol"
    @@ get [ s "page"; string; s "id"; string; s "access"; bool ]
  ;;

  let href_1 =
    test_case "generate link" `Quick (fun () ->
      let expected = "/user/xvw/age/36"
      and computed = Highway.html_href p1 [ "xvw"; 36 ] in
      check string "should be equal" expected computed)
  ;;

  let href_2 =
    test_case "generate link" `Quick (fun () ->
      let expected = "https://xvw.lol/page/about/id/uuu-xxx-ccc/access/true"
      and computed = Highway.html_href p2 [ "about"; "uuu-xxx-ccc"; true ] in
      check string "should be equal" expected computed)
  ;;
end

let cases = "Route Link Generation", [ href_1; href_2 ]
