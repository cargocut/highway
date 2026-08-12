(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** An extractor is a function that extracts arbitrary information
    from the [request]. Usually, these are query parameters. The
    extraction may succeed: [Ok 'query_params] or fail: [Error ()].
    Since the goal of an extractor is mostly to complete the routing,
    error can be no qualified since it pass the hand to the next
    route. *)

(** {1 Types} *)

(** A type describing an extraction over the request during the
    routing. *)
type ('request, 'query_params) t = 'request -> ('query_params, unit) result

(** {1 Helpers} *)

(** [nop] discard the observation of the request during the
    routing. *)
val nop : ('request, unit) t

(** {1 Query Params validation} *)

(** In many frameworks, it is often assumed that query parameters are
    represented as lists of strings. For example, the
    {{:https://ocaml.org/p/uri/latest} URI} module describes query
    parameters using the following type: [(string * string list) list]
    (we internally call it {b nested list}). On the other hand, Dream
    uses the representation [(string * string) list] (where it is
    assumed that keys may be repeated).

    Even if both approach are acceptable and usable, {b we asume thath
    [flatten list] are the happy path}. *)

(** {2 Types} *)

(** Raw Query Params where result are lists (Uri). *)
type nested_list = (string * string list) list

(** Raw Query Params where keys are duplicated (Dream). *)
type flatten_list = (string * string) list

(** {2 Request with query params validation} *)

(** [extract_from_nested get_query_params check] is a request handler
    that use [check] to validate query params extracted using
    [get_query] (that should returns a {!type:nested_list}.) *)
val extract_from_nested
  :  ('request -> nested_list)
  -> 'query_params Pidgin.Check.t
  -> ('request, 'query_params) t

(** [extract_from_flatten get_query_params check] is a request handler
    that use [check] to validate query params extracted using
    [get_query] (that should returns a {!type:flatten_list}.) *)
val extract_from_flatten
  :  ('request -> flatten_list)
  -> 'query_params Pidgin.Check.t
  -> ('request, 'query_params) t

(** See {!val:extract_from_flatten}. *)
val extract
  :  ('request -> flatten_list)
  -> 'query_params Pidgin.Check.t
  -> ('request, 'query_params) t

(** {2 Internals functions}

    Helpers for implementing more ambitious request handlers. *)

(** [from_nested_list pidgin_check list] validate the query params in
    the form of a nested list. *)
val from_nested_list
  :  'query_params Pidgin.Check.t
  -> nested_list
  -> ('query_params, unit) result

(** [from_flatten_list pidgin_check list] validate the query params in
    the form of a flatten list. *)
val from_flatten_list
  :  'query_params Pidgin.Check.t
  -> flatten_list
  -> ('query_params, unit) result
