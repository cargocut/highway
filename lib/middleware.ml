(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type ('request, 'response) t =
  ('request, 'response) Handler.t -> ('request, 'response) Handler.t

let fold others handler =
  let rec aux = function
    | [] -> handler
    | one :: others -> one (aux others)
  in
  aux others
;;
