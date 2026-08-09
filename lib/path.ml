(* Copyright (c) 2026, Cargocut and the Lunar developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type (_, _) t =
  | [] : (Void.t, Void.t) t
  | ( :: ) : ('a, 'b) Pattern.t * ('b, 'c) t -> ('a, 'c) t

let to_list pattern args =
  let rec aux : type a. string list -> (a, Void.t) t * a Args.t -> string list =
    fun acc -> function
      | [], [] -> List.rev acc
      | Literal s :: ps, xs -> aux (s :: acc) (ps, xs)
      | Hole hole :: ps, v :: xs ->
        let s = Hole.to_string hole v in
        aux (s :: acc) (ps, xs)
  in
  (pattern, args) |> aux []
;;

let from_list pattern path =
  let rec aux : type a. (a, Void.t) t * string list -> a Args.t option =
    function
    | [], [] -> Some []
    | Literal s :: ps, v :: xs ->
      if String.equal s v then aux (ps, xs) else None
    | Hole hole :: ps, x :: xs ->
      (match Hole.from_string hole x with
       | None -> None
       | Some k -> Option.bind (aux (ps, xs)) (fun ps -> Some Args.(k :: ps)))
    | [], _ | _ :: _, _ ->
      (* NOTE: The case where the pattern is larger, which should
         never happen because the lists are indexed. *)
      None
  in
  aux (pattern, path)
;;
