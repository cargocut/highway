(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Highway is a simple, framework-agnostic HTTP router. Its goal is
    to provide a highly abstract API based on the concepts of
    [response] and [request] so that it can, broadly speaking, be
    (probably) adapted to any framework in the OCaml ecosystem. *)

(** {1 Big Picture}

    The library allows you to define typed routes, enabling you to
    generate links using an API similar to the
    {{:https://ocaml.org/manual/5.5/api/Format.html} Format module},
    and to attach controllers to them, similar to the
    {{:https://ocaml.org/manual/5.5/api/Scanf.html} Scanf} module. *)

(** {1 Types}

    Re-exporting utility types to simplify the API. *)

(** [args] type describes a heterogeneous list used to generate links
    associated with a route. It can also serve as a controller
    parameter. *)
type 'a args = 'a Args.t

(** [hole] describes an arbitrary value that can be serialized or
    deserialized. They are used to describe route patterns that
    introduce variables. *)
type 'a hole = 'a Hole.t

(** [pattern] is a path fragment. It can be either a constant value
    (using the {!val:s} function) or a placeholder that introduces a
    variable (using {!type:hole}) into the path. *)
type ('a, 'b) pattern = ('a, 'b) Pattern.t

(** [path] is a heterogeneous list of {{!type:pattern} patterns}
    (which introduces holes in the final type signature). *)
type ('a, 'b) path = ('a, 'b) Path.t

(** [meth] describes an
    {{:https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods}
    HTTP method} in a rather simplistic way. Since certain
    capabilities are unlocked by using specific HTTP verbs, the
    representation of methods uses polymorphic variants to allow for
    intersections. *)
type meth = Method.t

(** Describes a set of query parameters
    ({{:https://en.wikipedia.org/wiki/Query_string} parameters in the
    query string}) associated with a validation strategy, as supported
    by the {{:https://ocaml.org/p/pidgin/latest} Pidgin
    library}. ['cstrs] allows you to specify whether you want to
    disallow query parameters (or not); ['ty] is the type to which you
    cast your set of parameters. *)
type ('cstrs, 'ty) param = ('cstrs, 'ty) Param.t

(** Describes the prohibition of parameters. *)
and nothing = Param.nothing

(** Describes the authorization of parameters. *)
and something = Param.something

(** A route is a combination of a scope ({!type:local} or
    {!type:global}), a {{!type:meth} method}, a {{!type:path} path},
    and a {{!type:param} query parameter validator}.

    Routes are the building blocks for creating services (a controller
    associated with a route) and for generating links for given routes
    while adhering to the typing defined by the holes in a path. *)
type ('scope, +'meth, 'cstrs, 'params_ty, 'k) route =
  ('scope, 'meth, 'cstrs, 'params_ty, 'k) Route.t

(** Describes the local scope (inside the application). *)
and local = Route.local

(** Describes the global scope (outside the application). *)
and global = Route.global

(** Describes a function from ['request] to ['response]. *)
type ('request, 'response) handler = ('request, 'response) Handler.t

(** Describes a middleware that extends a given {!type:handler}. *)
type ('request, 'response) middleware = ('request, 'response) Middleware.t

(** Describes a specific handler that passes a context to handlers. *)
type ('ctx, 'request, 'response) context = ('ctx, 'request, 'response) Context.t

(** Describes a service. A controller associated with a route. *)
type ('request, 'response) service = ('request, 'response) Service.t

(** {1 Describing patterns} *)

(** {2 Literal Pattern} *)

(** [s value] describes a {i Literal} pattern, a constant that does
    not introduce a variable into a pattern. *)
val s : string -> ('a, 'a) pattern

(** {2 Hole Pattern}

    You can define your own patterns using {!module:Hole} and
    {!module:Pattern}. *)

(** Describes a pattern that introduces a variable of type
    [string]. *)
val string : (string -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [int]. *)
val int : (int -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [float]. *)
val float : (float -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [char]. *)
val char : (char -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [bool]. *)
val bool : (bool -> 'a, 'a) pattern

(** Describes a potentially empty hole. It use [empty] to define if a
    value is present or not in a route path. *)
val opt : ?empty:string -> 'a hole -> ('a option -> 'b, 'b) pattern

(** {1 Query parameters}

    Allowing query parameters to be taken into account is a
    potentially debatable choice because, unlike the placeholders
    introduced in a route's patterns, the order of the parameters is
    of little importance. For this reason, all parameters observable
    in the router are processed by a parameter validation function.

    You can describe and compose more Query Param description using
    the module {!module:Param}. *)

(** Describes a validator that explicitly rejects all query
    parameters. *)
val discard_params : (nothing, unit) param

(** Describes a validator that explicitly ignores all query
    parameters. *)
val ignore_params : (something, unit) param

(** {2 Building Param description} *)

(** [make_params ~from_query ~to_query] Creates a query parameter
    validator.

    [from_query] uses a Pidgin record validator and [to_query]
    produces an associative list, where the arrays repeat the keys. *)
val make_params
  :  from_query:((string * Pidgin.Repr.t) list -> 'a Pidgin.Check.record)
  -> to_query:('a -> (string * string) list)
  -> (something, 'a) param

(** Same as {!val:make_params} but use a module. *)
val make_params'
  :  (module Sigs.AS_PARAM with type t = 'a)
  -> (something, 'a) param

(** {2 From holes}

    For "unique" query parameters, you can use {!module:Hole} to
    describe them "on the fly." *)

(** [param_from_hole ~key hole] define a single param indexed by [key]
    using a {!module:Hole} as validator. *)
val param_from_hole : key:string -> 'a hole -> (something, 'a) param

(** [opt_param_from_hole ~key hole] define a single optional param
    indexed by [key] using a {!module:Hole} as validator. *)
val opt_param_from_hole : key:string -> 'a hole -> (something, 'a option) param

(** {1 Routes} *)

(** {2 Building internal routes} *)

(** [get path] describes a local route, associated to the method [GET]
    for the given [path]. *)
val get
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `GET ], 'cstr, 'param_ty, 'k) route

(** [post path] describes a local route, associated to the method [POST]
    for the given [path]. *)
val post
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `POST ], 'cstr, 'param_ty, 'k) route

(** [connect path] describes a local route, associated to the method [CONNECT]
    for the given [path]. *)
val connect
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `CONNECT ], 'cstr, 'param_ty, 'k) route

(** [delete path] describes a local route, associated to the method [DELETE]
    for the given [path]. *)
val delete
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `DELETE ], 'cstr, 'param_ty, 'k) route

(** [head path] describes a local route, associated to the method [HEAD]
    for the given [path]. *)
val head
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `HEAD ], 'cstr, 'param_ty, 'k) route

(** [options path] describes a local route, associated to the method [OPTIONS]
    for the given [path]. *)
val options
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `OPTIONS ], 'cstr, 'param_ty, 'k) route

(** [patch path] describes a local route, associated to the method [PATCH]
    for the given [path]. *)
val patch
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `PATCH ], 'cstr, 'param_ty, 'k) route

(** [put path] describes a local route, associated to the method [PUT]
    for the given [path]. *)
val put
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `PUT ], 'cstr, 'param_ty, 'k) route

(** [query path] describes a local route, associated to the method [QUERY]
    for the given [path]. *)
val query
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `QUERY ], 'cstr, 'param_ty, 'k) route

(** [trace path] describes a local route, associated to the method [TRACE]
    for the given [path]. *)
val trace
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `TRACE ], 'cstr, 'param_ty, 'k) route

(** {2 Building global routes} *)

(** [global base_url local_route] makes [local_route] a global one. *)
val global
  :  string
  -> (local, 'meth, 'cstr, 'param_ty, 'k) route
  -> (global, 'meth, 'cstr, 'param_ty, 'k) route

(** {2 Link Generation}

    Routes are used to generate links and generally follow this pattern:
    [function ?anchor ?extra_params route args].

    They are backed by quoted versions that prevent extra parameters
    from being passed to routes that do not accept query
    parameters. *)

(** [html_href ?anchor ?extra_params route args param] generates a
    link that can be used in a [<a>] tag for a given [route] (using
    [args] and [param]). The link can be attached to [anchor] and
    [extra_params] *)
val html_href
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, Method.for_html_links, something, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [html_href' ?anchor route args param] same as {!val:html_href} but
    disallow [extra_params] (usable with [nothing] constraint). *)
val html_href'
  :  ?anchor:string
  -> ('scope, Method.for_html_links, 'cstrs, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [html_action ?anchor ?extra_params route args param] generates a
    link that can be used in a [<form action=...>] tag for a given
    [route] (using [args] and [param]). The link can be attached to
    [anchor] and [extra_params] *)
val html_action
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, Method.for_html_form, something, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [html_action' ?anchor route args param] same as {!val:html_action}
    but disallow [extra_params] (usable with [nothing] constraint). *)
val html_action'
  :  ?anchor:string
  -> ('scope, Method.for_html_form, 'cstrs, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [target ?anchor ?extra_params route args] compute a link for a
    given route, without any method constraints (this can be used, for
    example, to create [fetch] calls in JavaScript). *)
val target
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, 'meth, something, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [target' ?anchor route args param] same as {!val:target}
    but disallow [extra_params] (usable with [nothing] constraint). *)
val target'
  :  ?anchor:string
  -> ('scope, 'meth, 'cstrs, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** {1 Middleware}

    A middleware is a composable function that wraps a web handler to
    process a request before it reaches the handler and/or a response
    after it returns. *)

(** [middleware_list some_middlware] reduce a list of middleware into
    one, sequentially. It allows to collapse multiple middleware. *)
val middleware_list
  :  ('request, 'response) middleware list
  -> ('request, 'response) middleware

(** {1 Context}

    A context is a specific type of middleware that allows data to be
    injected arbitrarily into a service handler associated with a
    route. *)

(** No context, inject [unit] as a context. *)
val no_context : (unit, 'request, 'response) context

(** [value_context x] inject [x] as a context. *)
val value_context : 'a -> ('a, 'request, 'response) context

(** {1 Service}

    A service is a controller associated with a route. Along with
    {!type:route}, it is the main component of Highway. *)

(** [service ?middleware ?precondition ?postcondition ~context ~route handler]
    describes a service/controller. *)
val service
  :  ?middleware:('request, 'response) middleware
  -> ?precondition:('request -> bool)
  -> ?postcondition:('args args -> 'param_ty -> 'request -> bool)
  -> context:('ctx, 'request, 'response) context
  -> route:(local, meth, 'cstr, 'param_ty, 'args) route
  -> ('args args -> 'param_ty -> 'ctx -> ('request, 'response) handler)
  -> ('request, 'response) service

(** {1 Internal modules}

    Re-exporting internal modules (if functions are not re-exported in
    the main module). *)

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
