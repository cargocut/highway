(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Tools for validating query parameters at the router level. *)

(** There are several ways to represent query parameters. The library
    assumes that they are a list of [string * string], where keys can
    be repeated to describe arrays.

    The goal is to be associated with a route to enable the creation
    of links and the validation of query parameters when analyzing a
    route. *)

(** {1 Types} *)

(** Describes a device for processing query parameters
    (bidirectional). The [cstrs] can be {!type:nothing} or
    {!type:something}. *)
type ('cstrs, 'ty) t

(** Tag when you absolutely do not want query parameters. *)
type nothing = private Nothing

(** Tag used whe we probably want query parameters. *)
type something = private Something

(** {1 Building device} *)

(** [nop] describes a verified absence of query parameters. *)
val nop : (nothing, unit) t

(** [lax] describes the fact that query parameters are not taken into
    account in routing. *)
val lax : (something, unit) t

(** [define ~from_query ~to_query] describes a validation process for a
    set of query parameters. It use [Pidgin] for describing validation
    and since a set of query params is always a record, it use only a
    function that validate the body of a record.

    We do not relay on [Pidgin] for projection into query params
    because the language is too strong and allow to express strange
    behaviour in the context of simply flat key-value representation. *)
val define
  :  from_query:((string * Pidgin.Repr.t) list -> 'ty Pidgin.Check.record)
  -> to_query:('ty -> (string * string) list)
  -> (something, 'ty) t

(** [make (module P)] lift a module into a typed parameter. *)
val make : (module Sigs.AS_PARAM with type t = 'a) -> (something, 'a) t

(** [invmap device f g] map from [a] to [b]. *)
val invmap : (something, 'a) t -> ('a -> 'b) -> ('b -> 'a) -> (something, 'b) t

(** {1 Validate params} *)

(** [from_query param assoc_list] try to validate and extract the
    [assoc_list] using [param]. *)
val from_query : ('cstrs, 'ty) t -> (string * string) list -> 'ty option

(** {1 Render params} *)

(** [to_query_params params value] returns a list of query params. *)
val to_query_params : ('cstrs, 'ty) t -> 'ty -> (string * string) list

(** [to_query_strings params value] the computed query string. *)
val to_query_string : ('cstrs, 'ty) t -> 'ty -> string option

(** {1 Infix operators} *)

module Infix : sig
  (* Some Infix operators for composing with params definition. *)

  (** [device_a & device_b] compose the product of two devices. *)
  val ( & )
    :  (something, 'ty_a) t
    -> (something, 'ty_b) t
    -> (something, 'ty_a * 'ty_b) t

  (** [device_a / device_b] compose the sum of two devices. *)
  val ( / )
    :  (something, 'ty_a) t
    -> (something, 'ty_b) t
    -> (something, ('ty_a, 'ty_b) Either.t) t
end

include module type of Infix

(** {1 Misc} *)

(** [to_pidgin] Converts a list of query parameter mappings into a
    valid Pidgin object.*)
val to_pidgin : (string * string) list -> Pidgin.Repr.t
