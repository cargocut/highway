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

type ('scope, +'meth, 'cstrs, 'params_ty, 'k) route =
  ('scope, 'meth, 'cstrs, 'params_ty, 'k) Route.t
(**  *)

and local = Route.local
and global = Route.global

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
    in the router are processed by a parameter validation function. *)

(** Describes a validator that explicitly rejects all query
    parameters. *)
val discard_params : (nothing, unit) param

(** Describes a validator that explicitly ignores all query
    parameters. *)
val ignore_params : (something, unit) param

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

(** [param_from_hole ~key hole] define a single param indexed by [key]
    using a {!module:Hole} as validator. *)
val param_from_hole : key:string -> 'a hole -> (something, 'a) param

(** [opt_param_from_hole ~key hole] define a single optional param
    indexed by [key] using a {!module:Hole} as validator. *)
val opt_param_from_hole : key:string -> 'a hole -> (something, 'a option) param

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
