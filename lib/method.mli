(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Describes the HTTP methods (documented in
    {{:https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods}
    MDN}) with the exception of [Query], introduced by the
    {{:https://datatracker.ietf.org/doc/html/rfc10008} RFC10008}. *)

(** {1 Types} *)

(** The type that describes all HTTP methods. *)
type t =
  [ `CONNECT
  | `DELETE
  | `GET
  | `HEAD
  | `OPTIONS
  | `PATCH
  | `POST
  | `PUT
  | `QUERY
  | `TRACE
  ]

(** {2 Specialization}

    Certain methods cannot be used in certain contexts, so we
    specialise certain subsets of the types to provide relevant
    contexts of use. *)

(** Methods that can be used in HTML. *)
type for_html =
  [ `GET
  | `POST
  ]

(** Methods that can be used in HTML Forms. *)
type for_html_form = for_html

(** Methods that can be used in HTML Links. *)
type for_html_links = [ `GET ]

(** {1 Misc} *)

(** Equality between methods. *)
val equal : t -> t -> bool
