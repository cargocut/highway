(* Copyright (c) 2026, Cargocut and the Lunar developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

module Void = Void
module Args = Args
module Hole = Hole
module Pattern = Pattern
module Path = Path

type void = Void.t
type 'a hole = 'a Hole.t

type ('k, 'out) pattern = ('k, 'out) Pattern.t =
  | Literal : string -> ('a, 'a) pattern
  | Hole : 'a Hole.t -> ('a -> 'b, 'b) pattern

type 't args = 't Args.t =
  | [] : void args
  | ( :: ) : 'a * 'b args -> ('a -> 'b) args

type ('k, 'out) path = ('k, 'out) Path.t =
  | [] : (void, void) path
  | ( :: ) : ('a, 'b) pattern * ('b, 'c) path -> ('a, 'c) path

let s = Pattern.s
let string = Pattern.string
let int = Pattern.int
let float = Pattern.float
let char = Pattern.char
let bool = Pattern.bool
