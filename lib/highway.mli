(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Highway is a simple, framework-agnostic HTTP router. Its goal is
    to provide a highly abstract API based on the concepts of
    [response] and [request] so that it can, broadly speaking, be
    adapted to any framework in the OCaaml ecosystem. *)

(** {1 Types}

    Type aliases to make Highway easier to use. *)

(** The uninhabitable type. *)
type void = Void.t

(** Describe an HTTP method. *)
type meth = Method.t

(** The type that describes a hole. Its parameter, ['a], is the type
    of the hole. *)
type 'a hole = 'a Hole.t

(** The type describing a pattern, a fragment of a path (a segment is
    an element separated by slashes). It can be either a literal value
    or a {!type:hole}. *)
type ('k, 'out) pattern = ('k, 'out) Pattern.t =
  | Literal : string -> ('a, 'a) pattern
  | Hole : 'a Hole.t -> ('a -> 'b, 'b) pattern

(** The type that describes a road path, which is a heterogeneous list
    of {!type:pattern}. *)
type ('k, 'out) path = ('k, 'out) Path.t =
  | [] : ('a, 'a) path
  | ( :: ) : ('a, 'b) pattern * ('b, 'c) path -> ('a, 'c) path

(** Describes a heterogeneous list for filling {!type:path}. *)
type 't args = 't Args.t =
  | [] : void args
  | ( :: ) : 'a * 'b args -> ('a -> 'b) args

(** Describes a route. *)
type ('scope, +'meth, 'k) route = ('scope, 'meth, 'k) Route.t

(** Describes the local scope. *)
type local = Route.local

(** Describes the global scope. *)
type global = Route.global

(** A type describing a request handler. *)
type ('request, 'response) handler = ('request, 'response) Handler.t

(** A type describing a middleware. *)
type ('request, 'response) middleware = ('request, 'response) Middleware.t

(** A type describing an extraction over the request during the
    routing. *)
type ('request, 'query_params) request_handler =
  ('request, 'query_params) Request_handler.t

(** A type describing a context. *)
type ('ctx, 'request, 'response) context = ('ctx, 'request, 'response) Context.t

(** A type describing a service. *)
type ('request, 'response) service = ('request, 'response) Service.t

(** {1 Patterns}

    Pattern Construction (covered in the {!module:Pattern} module). *)

(** [s x] constructs a literal pattern. We use the notation [s], which
    is very concise. *)
val s : string -> ('a, 'a) pattern

(** {2 Holes}

    The holes make it possible to create specific patterns for route
    paths. *)

(** Describes a pattern that is a hole capturing [string]. *)
val string : (string -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [int]. *)
val int : (int -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [float]. *)
val float : (float -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [char]. *)
val char : (char -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [bool]. *)
val bool : (bool -> 'a, 'a) pattern

(** {1 Routes}

    Routes can be local, to describe resources within the application,
    or global, to describe external routes (and allow external links
    to be treated the same way as internal resources). *)

(** {2 Defining local routes} *)

(** [get path] describes a local route, associated to the method [GET]
    for the given [path]. *)
val get : ('k, void) path -> (local, [> `GET ], 'k) route

(** [post path] describes a local route, associated to the method [POST]
    for the given [path]. *)
val post : ('k, void) path -> (local, [> `POST ], 'k) route

(** [connect path] describes a local route, associated to the method [CONNECT]
    for the given [path]. *)
val connect : ('k, void) path -> (local, [> `CONNECT ], 'k) route

(** [delete path] describes a local route, associated to the method [DELETE]
    for the given [path]. *)
val delete : ('k, void) path -> (local, [> `DELETE ], 'k) route

(** [head path] describes a local route, associated to the method [HEAD]
    for the given [path]. *)
val head : ('k, void) path -> (local, [> `HEAD ], 'k) route

(** [options path] describes a local route, associated to the method [OPTIONS]
    for the given [path]. *)
val options : ('k, void) path -> (local, [> `OPTIONS ], 'k) route

(** [patch path] describes a local route, associated to the method [PATCH]
    for the given [path]. *)
val patch : ('k, void) path -> (local, [> `PATCH ], 'k) route

(** [put path] describes a local route, associated to the method [PUT]
    for the given [path]. *)
val put : ('k, void) path -> (local, [> `PUT ], 'k) route

(** [query path] describes a local route, associated to the method [QUERY]
    for the given [path]. *)
val query : ('k, void) path -> (local, [> `QUERY ], 'k) route

(** [trace path] describes a local route, associated to the method [TRACE]
    for the given [path]. *)
val trace : ('k, void) path -> (local, [> `TRACE ], 'k) route

(** {2 Defining global routes}

    A global route is defined in terms of a local route. *)

(** [global base_url local_route] makes [local_route] global. *)
val global : string -> (local, 'meth, 'k) route -> (global, 'meth, 'k) route

(** {2 Generate links for routes} *)

(** [html_href route args] generates a link that can be used in a [<a>]
    tag for a given [route] (using [args]). *)
val html_href : ('scope, Method.for_html_links, 'a) route -> 'a args -> string

(** [html_action route args] generates a link that can be used in a [<form action>]
    tag for a given [route] (using [args]). *)
val html_action : ('scope, Method.for_html_form, 'a) route -> 'a args -> string

(** [target route args] generates a link for a given [route] (using
    [args]) wihtout any constraints. *)
val target : ('scope, Method.t, 'a) route -> 'a args -> string

(** {1 Describing services}

    The services allow you to describe controllers associated with
    routes. *)

(** [service ?middleware ~context ~route handler] builds a service
    whose context is defined by the [contextual] parameter. The
    controller function takes as arguments the extracted parameters,
    the [args] from the [route], and the context, a request, and
    returns a response. The function [on_request] can be used to
    validate the request, extracting query parameters in an arbitrary
    representation. *)
val service
  :  ?middleware:('request, 'response) middleware
  -> on_request:('request -> ('query_params, unit) result)
  -> context:('ctx, 'request, 'response) context
  -> route:(local, meth, 'args) route
  -> ('args args -> 'query_params -> 'ctx -> ('request, 'response) handler)
  -> ('request, 'response) service

(** {2 Building contextes and request handler}

    Context are used to provision services using values that can be
    extracted from a request. *)

(** [const x] establishes a context for a constant value. *)
val const : 'a -> ('a, 'request, 'response) context

(** [unit] describes the [unit] context, which is used for
    {!val:service} services. *)
val unit : (unit, 'request, 'response) context

(** [no_request_handler] discard the obersvation of the request during
    the routing. *)
val no_request_handler : ('request, unit) request_handler

(** [query_params get_from_request check] is a request handler that
    use {{:https://ocaml.org/p/pidgin/latest} Pidgin} for validating
    query params extracted from the [get_from_request] function. See
    {!module:Request_handler} for more information. *)
val query_params
  :  ('request -> (string * string) list)
  -> 'query_params Pidgin.Check.t
  -> ('request, 'query_params) request_handler

(** {1 Dispatch services}

    Building a Router Based on a List of Services. *)

(** [dispatch ~given_method ~given_path services fallback] is a
    {!module:Middleware} which selects a candidate service from a list
    (based on the specified path and method; therefore, the order
    matters). If no candidate is found, the function executes the
    fallback. *)
val dispatch
  :  given_method:meth
  -> given_path:string list
  -> ('request, 'response) service list
  -> ('request, 'response) middleware

(** {1 Internal modules}

    Re-exporting internal modules (if functions are not re-exported in
    the main module). *)

module Void = Void
module Args = Args
module Hole = Hole
module Pattern = Pattern
module Path = Path
module Method = Method
module Route = Route
module Handler = Handler
module Middleware = Middleware
module Request_handler = Request_handler
module Context = Context
module Service = Service
