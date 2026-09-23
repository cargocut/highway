(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A Path describes the path to a resource; it is a heterogeneous
    list of {!module:Pattern}s that can be populated with
    {!module:Args}. *)

(** {1 Types} *)

(** Describes a route path as a heterogeneous list of patterns. Since
    the continuation is used only to describe how to interpret (or
    generate) a path, it always ends with {!type:Void.t}. *)
type (_, _) t =
  | [] : ('a, 'a) t
  | ( :: ) : ('a, 'b) Pattern.t * ('b, 'c) t -> ('a, 'c) t

(** {1 Compute path} *)

(** [to_list path args] calculates a list of strings that match the
    path defined by [path], filled in with the arguments from
    [args]. *)
val to_list : ('a, Void.t) t -> 'a Args.t -> string list

(** {1 Interpret path} *)

(** [from_list path input] calculates a list of arguments that match the
    [path] for the given [input]. This is one of the building blocks
    for creating a router. By default, the function does not perform
    any decoding except if you pass [~decode] flag. *)
val from_list
  :  ?decode:bool
  -> ('a, Void.t) t
  -> string list
  -> 'a Args.t option

(** {1 Misc} *)

(** [append tl1 tl2] concatenate [tl1] and [tl2]. *)
val append : ('a, 'b) t -> ('b, 'c) t -> ('a, 'c) t

module Infix : sig
  (** Some useful infix operators. *)

  (** [tl1 ++ tl2] is [append tl2 tl2], see {!val:append}. *)
  val ( ++ ) : ('a, 'b) t -> ('b, 'c) t -> ('a, 'c) t
end

include module type of Infix (** @inline *)
