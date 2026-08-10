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

    - ['scope] The scope of a route ([local] or [global]) used to
      specify whether a route identifies an internal link ([local]) or
      an external link ([global]).
    - ['meth] The method of a route, see {!module:Method}.
    - ['k] The typelevel continuation of the path.*)
type ('scope, +'meth, 'k) t

(** {2 Scopes} *)

(** Describes a local ressource. (Used as a tag for [scope]) *)
type local = private Local

(** Describes a global ressource. (Used as a tag for [scope]) *)
type global = private Global

(** {1 Definying local routes} *)

(** [get path] describes a local route, associated to the method [GET]
    for the given [path]. *)
val get : ('k, Void.t) Path.t -> (local, [> `GET ], 'k) t

(** [post path] describes a local route, associated to the method [POST]
    for the given [path]. *)
val post : ('k, Void.t) Path.t -> (local, [> `POST ], 'k) t

(** [connect path] describes a local route, associated to the method [CONNECT]
    for the given [path]. *)
val connect : ('k, Void.t) Path.t -> (local, [> `CONNECT ], 'k) t

(** [delete path] describes a local route, associated to the method [DELETE]
    for the given [path]. *)
val delete : ('k, Void.t) Path.t -> (local, [> `DELETE ], 'k) t

(** [head path] describes a local route, associated to the method [HEAD]
    for the given [path]. *)
val head : ('k, Void.t) Path.t -> (local, [> `HEAD ], 'k) t

(** [options path] describes a local route, associated to the method [OPTIONS]
    for the given [path]. *)
val options : ('k, Void.t) Path.t -> (local, [> `OPTIONS ], 'k) t

(** [patch path] describes a local route, associated to the method [PATCH]
    for the given [path]. *)
val patch : ('k, Void.t) Path.t -> (local, [> `PATCH ], 'k) t

(** [put path] describes a local route, associated to the method [PUT]
    for the given [path]. *)
val put : ('k, Void.t) Path.t -> (local, [> `PUT ], 'k) t

(** [query path] describes a local route, associated to the method [QUERY]
    for the given [path]. *)
val query : ('k, Void.t) Path.t -> (local, [> `QUERY ], 'k) t

(** [trace path] describes a local route, associated to the method [TRACE]
    for the given [path]. *)
val trace : ('k, Void.t) Path.t -> (local, [> `TRACE ], 'k) t

(** {1 Definying global routes}

    A global route is defined in terms of a local route. *)

(** [global base_url local_route] makes [local_route] global. *)
val global : string -> (local, 'meth, 'k) t -> (global, 'meth, 'k) t

(** {1 Compute links from route} *)

(** [html_href route args] generates a link that can be used in a [<a>]
    tag for a given [route] (using [args]). *)
val html_href : ('scope, Method.for_html_links, 'a) t -> 'a Args.t -> string

(** [html_action route args] generates a link that can be used in a [<form action>]
    tag for a given [route] (using [args]). *)
val html_action : ('scope, Method.for_html_form, 'a) t -> 'a Args.t -> string

(** [target route args] generates a link for a given [route] (using
    [args]) wihtout any constraints. *)
val target : ('scope, Method.t, 'a) t -> 'a Args.t -> string

(** [to_list ?include_base_url route args] generate a link as a list
    of string for the given [route] according to the given [args]. *)
val to_list
  :  ?include_base_url:bool
  -> ('scope, Method.t, 'a) t
  -> 'a Args.t
  -> string list

(** {1 Misc} *)

(** [path route] returns the path of a given [route] *)
val path : ('scope, _, 'k) t -> ('k, Void.t) Path.t

(** [base_url route] returns the root of a global [route]. *)
val base_url : (global, _, _) t -> string
