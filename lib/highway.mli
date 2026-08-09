(* Copyright (c) 2026, Cargocut and the Lunar developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Highway is a simple, framework-agnostic HTTP router. Its goal is
    to provide a highly abstract API based on the concepts of
    [response] and [request] so that it can, broadly speaking, be
    adapted to any framework in the OCaaml ecosystem. *)

(** {1 Types}

    Type aliases to make Highway easier to use. *)

(** The uninhabitable type. *)
type void = Void.t

(** The type that describes a hole. Its parameter, ['a], is the type
    of the hole. *)
type 'a hole = 'a Hole.t

(** The type describing a pattern, a fragment of a path (a segment is
    an element separated by slashes). It can be either a literal value
    or a {!type:hole}. *)
type ('k, 'out) pattern = ('k, 'out) Pattern.t =
  | Literal : string -> ('a, 'a) pattern
  | Hole : 'a Hole.t -> ('a -> 'b, 'b) pattern

(** Describes a heterogeneous list. *)
type 't args = 't Args.t =
  | [] : void args
  | ( :: ) : 'a * 'b args -> ('a -> 'b) args

(** {1 Patterns}

    Pattern Construction (covered in the {!module:Pattern} module). *)

(** [s x] constructs a literal pattern. We use the notation [s], which
    is very concise. *)
val s : string -> ('a, 'a) pattern

(** {2 Holes} *)

(** Describes a pattern that is a hole capturing [string]. *)
val string : (string -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [int]. *)
val int : (int -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [float]. *)
val float : (float -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [char]. *)
val char : (char -> 'a, 'a) pattern

(** Describes a pattern that is a hole capturing [bool]. *)
val bool : (bool -> 'a, 'a) pattern

(** {1 Internal modules}

    Re-exporting internal modules (if functions are not re-exported in
    the main module). *)

module Void = Void
module Args = Args
module Hole = Hole
module Pattern = Pattern
