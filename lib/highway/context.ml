(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type ('kind, 'request, 'response) t =
  ('kind -> ('request, 'response) Handler.t) -> ('request, 'response) Handler.t

let const value handler = handler value
let unit handler = const () handler
