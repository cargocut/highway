(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Set of Reusable Interfaces. *)

module type AS_PARAM = sig
  (** If a module implements this interface for a type [t], it can be
      used to quickly describe a set of query parameters. *)

  type t

  (** Validate a Key Value list from the request. *)
  val check_param : (string * Pidgin.Repr.t) list -> t Pidgin.Check.record

  (** Render a set of paramaters into a Key Value List. *)
  val render_param : t -> (string * string) list
end
