(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A route is the combination of a {{!type:Method.t} method}, a
    {{!type:Path.t} path} and {{!type:Param.t} set of query
    parameters}. It allows you to identify resources and is used to
    describe internal (local) links and external (global) links, which
    can be associated with controllers to create services. *)

(** {1 Types} *)

(** A route is defined by three types of parameters:

    - ['scope] The scope of a route ([local] or [global]) used to
      specify whether a route identifies an internal link ([local]) or
      an external link ([global]).
    - ['meth] The method of a route, see {!module:Method}.
    - ['cstrs] The nature of the query parameters ([nothig] or [something]).
    - ['param_ty] The type of extracted query parameters.
    - ['k] The typelevel continuation of the path.*)
type ('scope, +'meth, 'cstrs, 'param_ty, 'k) t

(** {2 Scopes} *)

(** Describes a local ressource. (Used as a tag for [scope]) *)
type local = private Local

(** Describes a global ressource. (Used as a tag for [scope]) *)
type global = private Global

(** {1 Definying local routes} *)

(** [get path] describes a local route, associated to the method [GET]
    for the given [path]. *)
val get
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `GET ], 'cstr, 'param_ty, 'k) t

(** [post path] describes a local route, associated to the method [POST]
    for the given [path]. *)
val post
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `POST ], 'cstr, 'param_ty, 'k) t

(** [connect path] describes a local route, associated to the method [CONNECT]
    for the given [path]. *)
val connect
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `CONNECT ], 'cstr, 'param_ty, 'k) t

(** [delete path] describes a local route, associated to the method [DELETE]
    for the given [path]. *)
val delete
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `DELETE ], 'cstr, 'param_ty, 'k) t

(** [head path] describes a local route, associated to the method [HEAD]
    for the given [path]. *)
val head
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `HEAD ], 'cstr, 'param_ty, 'k) t

(** [options path] describes a local route, associated to the method [OPTIONS]
    for the given [path]. *)
val options
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `OPTIONS ], 'cstr, 'param_ty, 'k) t

(** [patch path] describes a local route, associated to the method [PATCH]
    for the given [path]. *)
val patch
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `PATCH ], 'cstr, 'param_ty, 'k) t

(** [put path] describes a local route, associated to the method [PUT]
    for the given [path]. *)
val put
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `PUT ], 'cstr, 'param_ty, 'k) t

(** [query path] describes a local route, associated to the method [QUERY]
    for the given [path]. *)
val query
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `QUERY ], 'cstr, 'param_ty, 'k) t

(** [trace path] describes a local route, associated to the method [TRACE]
    for the given [path]. *)
val trace
  :  ('k, Void.t) Path.t
  -> ('cstr, 'param_ty) Param.t
  -> (local, [> `TRACE ], 'cstr, 'param_ty, 'k) t

(** {1 Definying global routes}

    A global route is defined in terms of a local route. *)

(** [global base_url local_route] makes [local_route] global. *)
val global
  :  string
  -> (local, 'meth, 'cstr, 'param_ty, 'k) t
  -> (global, 'meth, 'cstr, 'param_ty, 'k) t

(** {1 Compute links from route} *)

(** [html_href ?anchor ?extra_params route args param] generates a
    link that can be used in a [<a>] tag for a given [route] (using
    [args] and [param]). The link can be attached to [anchor] and [extra_params]
*)
val html_href
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, Method.for_html_links, Param.something, 'param_ty, 'args) t
  -> 'args Args.t
  -> 'param_ty
  -> string

(** [html_href' ?anchor route args param] is like {!val:html_href}
    disallowing [extra_params] (to ensure that params indexed by
    {!val:Param.nop} are reachable by the router). *)
val html_href'
  :  ?anchor:string
  -> ('scope, Method.for_html_links, 'cstrs, 'param_ty, 'args) t
  -> 'args Args.t
  -> 'param_ty
  -> string

(** [html_action ?anchor ?extra_params route args param] generates a
    link that can be used in a [<form action=...>] tag for a given [route] (using
    [args] and [param]). The link can be attached to [anchor] and [extra_params]
*)
val html_action
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, Method.for_html_form, Param.something, 'param_ty, 'args) t
  -> 'args Args.t
  -> 'param_ty
  -> string

(** [html_action' ?anchor route args] is like {!val:html_action}
    disallowing [extra_params] (to ensure that params indexed by
    {!val:Param.nop} are reachable by the router). *)
val html_action'
  :  ?anchor:string
  -> ('scope, Method.for_html_form, 'cstrs, 'param_ty, 'args) t
  -> 'args Args.t
  -> 'param_ty
  -> string

(** [target ?anchor ?extra_params route args] compute a link for a
    given route, without any method constraints (this can be used, for
    example, to create [fetch] calls in JavaScript). *)
val target
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, 'meth, Param.something, 'param_ty, 'args) t
  -> 'args Args.t
  -> 'param_ty
  -> string

(** [target' ?anchor route args] is like {!val:target}
    disallowing [extra_params] (to ensure that params indexed by
    {!val:Param.nop} are reachable by the router). *)
val target'
  :  ?anchor:string
  -> ('scope, 'meth, 'cstrs, 'param_ty, 'args) t
  -> 'args Args.t
  -> 'param_ty
  -> string

(** {1 Extracting values} *)

(** [has_method given_meth route] check if the given [route] has the
    [given_meth]. *)
val has_method : Method.t -> ('scope, Method.t, _, _, _) t -> bool

(** Extract values for routing. *)
val extract_values
  :  (local, Method.t, 'cstr, 'param_ty, 'args) t
  -> given_path:string list
  -> given_query_params:(string * string) list
  -> ('args Args.t * 'param_ty) option

(** {1 Misc} *)

(** [path route] returns the path of a given [route] *)
val path : ('scope, _, _, _, 'k) t -> ('k, Void.t) Path.t

(** [query_params route] returns the query param device of a given [route] *)
val query_params : (_, _, 'cstr, 'ty, _) t -> ('cstr, 'ty) Param.t

(** [base_url route] returns the root of a global [route]. *)
val base_url : (global, _, _, _, _) t -> string
