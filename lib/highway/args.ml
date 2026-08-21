(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type _ t =
  | [] : Void.t t
  | ( :: ) : 'a * 'b t -> ('a -> 'b) t
