(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A context is a type of middleware that allows a value to be passed
    to the handler functions assigned to services. *)

(** {1 Types} *)

(** Describes a specific handler that passes a context to handlers. *)
type ('ctx, 'request, 'response) t =
  ('ctx -> ('request, 'response) Handler.t) -> ('request, 'response) Handler.t

(** {1 Pre-built contexts} *)

(** [const x] establishes a context for a constant value. *)
val const : 'a -> ('a, 'request, 'response) t

(** [unit] describes the [unit] context. *)
val unit : (unit, 'request, 'response) t
