(* Copyright (c) 2026, Cargocut and the Lunar developers.
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
  | [] : (Void.t, Void.t) t
  | ( :: ) : ('a, 'b) Pattern.t * ('b, 'c) t -> ('a, 'c) t

(** {1 Compute path} *)

(** [to_list pattern args] calculates a list of strings that match the
    path defined by [pattern], filled in with the arguments from
    [args]. *)
val to_list : ('a, Void.t) t -> 'a Args.t -> string list

(** {1 Interpret path} *)

(** [from_list pattern path] calculates a list of arguments that match
    the [pattern] for the given [path]. This is one of the building
    blocks for creating a router. *)
val from_list : ('a, Void.t) t -> string list -> 'a Args.t option
