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

(** {1 Patterns}

    Pattern Construction (covered in the {!module:Pattern} module). *)

(** [s x] constructs a literal pattern. We use the notation [s], which
    is very concise. *)
val s : string -> ('a, 'a) pattern

(** {2 Holes} *)

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
