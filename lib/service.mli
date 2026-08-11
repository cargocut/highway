(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** *)

(** {1 Types} *)

type ('request, 'response) t

(** {1 Building services} *)

val simple
  :  ?middleware:('request, 'response) Middleware.t
  -> route:(Route.local, Method.t, 'args) Route.t
  -> ('args Args.t -> unit -> ('request, 'response) Handler.t)
  -> ('request, 'response) t

val contextual
  :  ?middleware:('request, 'response) Middleware.t
  -> context:
       (('context -> ('request, 'response) Handler.t)
        -> ('request, 'response) Handler.t)
  -> route:(Route.local, Method.t, 'args) Route.t
  -> ('args Args.t -> 'context -> ('request, 'response) Handler.t)
  -> ('request, 'response) t

(** {1 Routing services} *)

val dispatch
  :  given_method:Method.t
  -> given_path:string list
  -> fallback:('request, 'response) Handler.t
  -> ('request, 'response) t list
  -> ('request, 'response) Handler.t
