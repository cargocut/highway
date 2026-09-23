(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Utilities for encoding reserved characters as percentages, in partial
    accordance with {{:https://datatracker.ietf.org/doc/html/rfc3986}
    RFC 3986}. *)

(** {1 Encoding and Decoding} *)

(** [encode ~is_allowed string] will apply pct_encoding to the string for
    characters that are not allowed (as defined by the [is_allowed]
    function). *)
val encode : is_allowed:(char -> bool) -> string -> string

(** [decode ?plus_as_space string] decode the pct_encoding to the given
    string. *)
val decode : ?plus_as_space:bool -> string -> string

(** {1 Encoding function} *)

(** Function for regular unreserved chars. *)
val is_unreserved : char -> bool

(** A suitable function for path segment. [plus_as_space] can replace
    spaces by [+] instead of [%20]. *)
val is_path_segment : char -> bool

(** A suitable function for query components. *)
val is_query_component : char -> bool
