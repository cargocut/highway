(* Copyright (c) 2026, Cargocut and the Lunar developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type 'a t =
  { to_string : 'a -> string
  ; from_string : string -> 'a option
  }

let invmap f g { to_string; from_string } =
  { to_string = (fun x -> to_string (f x))
  ; from_string = (fun x -> x |> from_string |> Option.map g)
  }
;;

let make ~to_string ~from_string = { to_string; from_string }
let to_string { to_string; _ } x = to_string x
let from_string { from_string; _ } x = from_string x
let string = make ~to_string:Fun.id ~from_string:Option.some
let int = make ~to_string:string_of_int ~from_string:int_of_string_opt
let float = make ~to_string:string_of_float ~from_string:float_of_string_opt

let char =
  make ~to_string:(String.make 1) ~from_string:(fun x ->
    if String.length x = 1 then Some x.[0] else None)
;;

let bool =
  make
    ~to_string:(function
      | true -> "true"
      | false -> "false")
    ~from_string:(fun x ->
      match String.lowercase_ascii x with
      | "true" -> Some true
      | "false" -> Some false
      | _ -> None)
;;
