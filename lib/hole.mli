(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A hole is a fragment of a URL that describes a variable (which
    must be filled in) when interpreting a service or constructing a
    link. It is used to describe a {!module:Pattern}. *)

(** {1 Types} *)

(** The type that describes a hole. Its parameter, ['a], is the type
    of the hole. *)
type 'a t

(** {1 Building holes} *)

(** [make ~to_string ~from_string] make a new hole. *)
val make : to_string:('a -> string) -> from_string:(string -> 'a option) -> 'a t

(** {1 Operating holes} *)

(** [to_string hole value] uses a [hole] to serialize arbitrary data,
    [value]. *)
val to_string : 'a t -> 'a -> string

(** [from_string hole repr] uses a [hole] to deserialize a string
    [repr]. *)
val from_string : 'a t -> string -> 'a option

(** [invmap into from hole] hole mapping. Since a hole has two
    functions (contravariant and covariant), a hole is in fact an
    invariant functor. *)
val invmap : ('a -> 'b) -> ('b -> 'a) -> 'b t -> 'a t

(** {1 Pre-built holes}

    Set of pre-built holes (mapping primarily to primitive types). *)

(** A hole that catches [string]. *)
val string : string t

(** A hole that catches [int]. *)
val int : int t

(** A hole that catches [float]. *)
val float : float t

(** A hole that catches [char]. *)
val char : char t

(** A hole that catches [bool]. *)
val bool : bool t
