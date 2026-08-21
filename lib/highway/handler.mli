(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** A handler describes a function that takes a response as an
    argument and returns a request. Since Highway is generic, the
    library makes no assumptions about the type of the request or
    response; this is left to specialized frameworks. *)

(** {1 Types} *)

(** A type describing a request handler. *)
type ('request, 'response) t = 'request -> 'response
