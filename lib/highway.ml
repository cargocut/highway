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

type ('request, 'response) handler = ('request, 'response) Handler.t
type ('request, 'response) middleware = ('request, 'response) Middleware.t
type ('ctx, 'request, 'response) context = ('ctx, 'request, 'response) Context.t
type ('request, 'response) service = ('request, 'response) Service.t

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
let global = Route.global

(* Route generation *)

let html_href = Route.html_href
let html_href' = Route.html_href'
let html_action = Route.html_action
let html_action' = Route.html_action'
let target = Route.target
let target' = Route.target'

(* Middleware *)

let middleware_list = Middleware.fold

(* Context *)

let no_context = Context.unit
let value_context = Context.const

(* Service *)

let service = Service.make
let dispatch = Service.dispatch
