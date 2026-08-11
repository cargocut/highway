(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

module Void = Void
module Args = Args
module Hole = Hole
module Pattern = Pattern
module Path = Path
module Method = Method
module Route = Route
module Handler = Handler
module Middleware = Middleware

(* Shortcuts and aliases *)

type void = Void.t
type meth = Method.t
type 'a hole = 'a Hole.t

type ('k, 'out) pattern = ('k, 'out) Pattern.t =
  | Literal : string -> ('a, 'a) pattern
  | Hole : 'a Hole.t -> ('a -> 'b, 'b) pattern

type 't args = 't Args.t =
  | [] : void args
  | ( :: ) : 'a * 'b args -> ('a -> 'b) args

type ('k, 'out) path = ('k, 'out) Path.t =
  | [] : ('a, 'a) path
  | ( :: ) : ('a, 'b) pattern * ('b, 'c) path -> ('a, 'c) path

type ('scope, +'meth, 'k) route = ('scope, 'meth, 'k) Route.t
type local = Route.local
type global = Route.global
type ('request, 'response) handler = ('request, 'response) Handler.t
type ('request, 'response) middleware = ('request, 'response) Middleware.t

(* Patterns and Holes *)

let s = Pattern.s
let string = Pattern.string
let int = Pattern.int
let float = Pattern.float
let char = Pattern.char
let bool = Pattern.bool

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

(* Routes generation *)

let html_href = Route.html_href
let html_action = Route.html_action
let target = Route.target
