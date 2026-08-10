(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Describes a heterogeneous list that uses arrow notation to
    characterize the various elements of the list.

    The purpose of the list is solely to define route arguments. Its
    set of operations is therefore limited. *)

(** {1 Types} *)

(** Describes a heterogeneous list. *)
type _ t =
  | [] : Void.t t
  | ( :: ) : 'a * 'b t -> ('a -> 'b) t
