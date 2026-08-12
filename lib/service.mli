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
    returns a response. The function [on_request] can be used to
    validate the request, extracting query parameters in an arbitrary
    representation. *)
val make
  :  ?middleware:('request, 'response) Middleware.t
  -> on_request:('request -> ('query_params, unit) result)
  -> context:('ctx, 'request, 'response) Context.t
  -> route:(Route.local, Method.t, 'args) Route.t
  -> ('args Args.t -> 'query_params -> 'ctx -> ('request, 'response) Handler.t)
  -> ('request, 'response) t

(** {1 Routing services}

    The routing procedure allows you to select a candidate service
    from a list based on a method and a path (represented as a list of
    strings). This makes it possible to build generic routers. *)

(** [dispatch ~given_method ~given_path services fallback] is a
    {!module:Middleware} which selects a candidate service from a list
    (based on the specified path and method; therefore, the order
    matters). If no candidate is found, the function executes the
    fallback. *)
val dispatch
  :  given_method:Method.t
  -> given_path:string list
  -> ('request, 'response) t list
  -> ('request, 'response) Middleware.t
