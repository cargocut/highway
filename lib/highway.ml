(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

module Void = Void
module Sigs = Sigs
module Args = Args
module Hole = Hole
module Pattern = Pattern
module Path = Path
module Method = Method
module Route = Route
module Handler = Handler
module Middleware = Middleware
module Context = Context
module Param = Param
module Service = Service

(* Type aliases *)

type 'a args = 'a Args.t
type 'a hole = 'a Hole.t
type ('a, 'b) pattern = ('a, 'b) Pattern.t
type ('a, 'b) path = ('a, 'b) Path.t
type meth = Method.t

type ('cstrs, 'ty) param = ('cstrs, 'ty) Param.t
and nothing = Param.nothing
and something = Param.something

type ('scope, +'meth, 'cstrs, 'params_ty, 'k) route =
  ('scope, 'meth, 'cstrs, 'params_ty, 'k) Route.t

and local = Route.local
and global = Route.global

(* Pattern definition *)

let s = Pattern.s
let string = Pattern.string
let int = Pattern.int
let float = Pattern.float
let char = Pattern.char
let bool = Pattern.bool
let opt = Pattern.opt

(* Params *)

let discard_params = Param.nop
let ignore_params = Param.lax
let make_params = Param.define
let make_params' = Param.make
let param_from_hole = Param.from_hole
let opt_param_from_hole = Param.from_opt_hole

(* Routes *)

let get = Route.get
let post = Route.post
let connect = Route.connect
let delete = Route.delete
let head = Route.head
let options = Route.options
let patch = Route.patch
let put = Route.put
let query = Route.query
let trace = Route.trace
