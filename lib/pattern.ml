(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type (_, _) t =
  | Literal : string -> ('a, 'a) t
  | Hole : 'a Hole.t -> ('a -> 'b, 'b) t

let s x = Literal x
let string = Hole Hole.string
let int = Hole Hole.int
let char = Hole Hole.char
let float = Hole Hole.float
let bool = Hole Hole.bool
let opt ?empty hole = Hole (Hole.opt ?empty hole ())
