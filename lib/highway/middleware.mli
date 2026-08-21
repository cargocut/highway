(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A middleware is a composable function that wraps a web handler to
    process a request before it reaches the handler and/or a response
    after it returns. *)

(** {1 Types} *)

(** A type describing a middleware. *)
type ('request, 'response) t =
  ('request, 'response) Handler.t -> ('request, 'response) Handler.t

(** {1 Utils} *)

(** [fold some_middlware handler] reduce a list of middleware into
    one, sequentially. It allows to collapse multiple middleware. *)
val fold : ('request, 'response) t list -> ('request, 'response) t
