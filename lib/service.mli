(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A service (or controller) maps a route to an execution function
    (the response to a request). To remain generic, a service is
    parametrized by a request and a response. *)

(** {1 Types} *)

(** The type that describes a service (which takes a request as an
    argument and returns a response). *)
type ('request, 'response) t

(** {1 Building services}

    Building a service involves associating a route with middleware
    (which can be collapsed using {!val:Middleware.fold}), a context
    provider (to add additional data), and a function that is executed
    when a route matches a request. *)

(** [make ?middleware ~on_query ~context ~route handler] builds a
    service whose context is defined by the [context] parameter. The
    controller function takes as arguments the extracted parameters,
    the [args] from the [route], and the context, a request, and
    returns a response. *)
val make
  :  ?middleware:('request, 'response) Middleware.t
  -> context:('ctx, 'request, 'response) Context.t
  -> route:(Route.local, Method.t, 'cstr, 'param_ty, 'args) Route.t
  -> ('args Args.t -> 'param_ty -> 'ctx -> ('request, 'response) Handler.t)
  -> ('request, 'response) t

(** [make_simple] is like [make] but without extractor and without
    context. *)
val make_simple
  :  ?middleware:('request, 'response) Middleware.t
  -> route:(Route.local, Method.t, Param.something, unit, 'args) Route.t
  -> ('args Args.t -> ('request, 'response) Handler.t)
  -> ('request, 'response) t

(** {1 Routing services}

    The routing procedure allows you to select a candidate service
    from a list based on a method and a path (represented as a list of
    strings). This makes it possible to build generic routers. *)

(** [dispatch ~given_method ~given_path ~given_query_params services fallback] is a
    {!module:Middleware} which selects a candidate service from a list
    (based on the specified path and method; therefore, the order
    matters). If no candidate is found, the function executes the
    fallback. *)
val dispatch
  :  given_method:Method.t
  -> given_path:string list
  -> given_query_params:(string * string) list
  -> ('request, 'response) t list
  -> ('request, 'response) Middleware.t
