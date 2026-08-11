(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type t =
  [ `GET
  | `HEAD
  | `OPTIONS
  | `TRACE
  | `PUT
  | `DELETE
  | `POST
  | `PATCH
  | `CONNECT
  | `QUERY
  ]

type for_html =
  [ `GET
  | `POST
  ]

type for_html_form = for_html
type for_html_links = [ `GET ]

(* NOTE: Looking at
   https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods,
   We would probably like to encode more invariants (for example,
   whether something is safe, idempotent, etc.); however, I have not
   yet come across any relevant use cases (at least as type
   indices). *)

let equal a b =
  match a, b with
  | `GET, `GET
  | `HEAD, `HEAD
  | `OPTIONS, `OPTIONS
  | `TRACE, `TRACE
  | `PUT, `PUT
  | `DELETE, `DELETE
  | `POST, `POST
  | `PATCH, `PATCH
  | `CONNECT, `CONNECT
  | `QUERY, `QUERY -> true
  | `GET, _
  | `HEAD, _
  | `OPTIONS, _
  | `TRACE, _
  | `PUT, _
  | `DELETE, _
  | `POST, _
  | `PATCH, _
  | `CONNECT, _
  | `QUERY, _ -> false
;;
