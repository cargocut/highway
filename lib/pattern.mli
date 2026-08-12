(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A pattern is a fragment of a path (a segment is an element
    separated by slashes). It can be either a literal value or a
    {!module:Hole}. *)

(** {1 Types} *)

(** The type describing a pattern. The first type parameter describes
    the typed continuation, and the second describes the
    continuation's return value. In practice, `Void.t` is used as the
    return value. The type is not left abstract to allow users to
    describe new holes without being subject to the
    {{:https://ocaml.org/manual/5.2/polymorphism.html#ss:valuerestriction}
    value restriction}. *)
type (_, _) t =
  | Literal : string -> ('a, 'a) t
  | Hole : 'a Hole.t -> ('a -> 'b, 'b) t

(** {1 Building patterns} *)

(** [s x] constructs a literal pattern. We use the notation [s], which
    is very concise. *)
val s : string -> ('a, 'a) t

(** {2 Holes} *)

(** Describes a pattern that is a hole capturing [string]. *)
val string : (string -> 'a, 'a) t

(** Describes a pattern that is a hole capturing [int]. *)
val int : (int -> 'a, 'a) t

(** Describes a pattern that is a hole capturing [float]. *)
val float : (float -> 'a, 'a) t

(** Describes a pattern that is a hole capturing [char]. *)
val char : (char -> 'a, 'a) t

(** Describes a pattern that is a hole capturing [bool]. *)
val bool : (bool -> 'a, 'a) t

(** Describes a potentially empty hole. *)
val opt : ?empty:string -> 'a Hole.t -> ('a option -> 'b, 'b) t
