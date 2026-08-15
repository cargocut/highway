(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

let () =
  Alcotest.run
    "Highway main suite"
    [ Path_projection_test.cases
    ; Path_handling_test.cases
    ; Param_test.cases
    ; Route_projection_test.cases
    ; Routing_test.cases
    ; Rw_example_test.cases
    ]
;;
