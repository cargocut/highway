(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A route is the combination of a {{!type:Method.t} method} and a
    {{!type:Path.t} path}. It allows you to identify resources and is
    used to describe internal (local) links and external (global)
    links, which can be associated with controllers to create
    services. *)

(** {1 Types} *)

(** A route is defined by three types of parameters:

    - ['scope] The scope of a route ([`Local] or [`Global]) used to
      specify whether a route identifies an internal link ([`Local]) or
      an external link ([`Global]).
    - ['meth] The method of a route, see {!module:Method}.
    - ['k] The typelevel continuation of the path.*)
type ('scope, +'meth, 'k) t

(** {1 Definying local routes} *)

(** [get path] describes a local route, associated to the method [GET]
    for the given [path]. *)
val get : ('k, Void.t) Path.t -> ([> `Local ], [> `GET ], 'k) t

(** [post path] describes a local route, associated to the method [POST]
    for the given [path]. *)
val post : ('k, Void.t) Path.t -> ([> `Local ], [> `POST ], 'k) t

(** [connect path] describes a local route, associated to the method [CONNECT]
    for the given [path]. *)
val connect : ('k, Void.t) Path.t -> ([> `Local ], [> `CONNECT ], 'k) t

(** [delete path] describes a local route, associated to the method [DELETE]
    for the given [path]. *)
val delete : ('k, Void.t) Path.t -> ([> `Local ], [> `DELETE ], 'k) t

(** [head path] describes a local route, associated to the method [HEAD]
    for the given [path]. *)
val head : ('k, Void.t) Path.t -> ([> `Local ], [> `HEAD ], 'k) t

(** [options path] describes a local route, associated to the method [OPTIONS]
    for the given [path]. *)
val options : ('k, Void.t) Path.t -> ([> `Local ], [> `OPTIONS ], 'k) t

(** [patch path] describes a local route, associated to the method [PATCH]
    for the given [path]. *)
val patch : ('k, Void.t) Path.t -> ([> `Local ], [> `PATCH ], 'k) t

(** [put path] describes a local route, associated to the method [PUT]
    for the given [path]. *)
val put : ('k, Void.t) Path.t -> ([> `Local ], [> `PUT ], 'k) t

(** [query path] describes a local route, associated to the method [QUERY]
    for the given [path]. *)
val query : ('k, Void.t) Path.t -> ([> `Local ], [> `QUERY ], 'k) t

(** [trace path] describes a local route, associated to the method [TRACE]
    for the given [path]. *)
val trace : ('k, Void.t) Path.t -> ([> `Local ], [> `TRACE ], 'k) t

(** {1 Definying global routes}

    A global route is defined in terms of a local route. *)

(** [global base_url local_route] makes [local_route] global. *)
val global : string -> ([ `Local ], 'meth, 'k) t -> ([> `Global ], 'meth, 'k) t

(** {1 Compute links from route} *)

(** [html_href route args] generates a link that can be used in a [<a>]
    tag for a given [route] (using [args]). *)
val html_href
  :  ([ `Global | `Local ], Method.for_html_links, 'a) t
  -> 'a Args.t
  -> string

(** [html_action route args] generates a link that can be used in a [<form action>]
    tag for a given [route] (using [args]). *)
val html_action
  :  ([ `Global | `Local ], Method.for_html_form, 'a) t
  -> 'a Args.t
  -> string

(** [target route args] generates a link for a given [route] (using
    [args]) wihtout any constraints. *)
val target : ([ `Global | `Local ], Method.t, 'a) t -> 'a Args.t -> string
