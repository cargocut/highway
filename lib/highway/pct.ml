(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

let hex = "0123456789ABCDEF"

let unhex = function
  | '0' .. '9' as c -> Some (Char.code c - Char.code '0')
  | 'a' .. 'f' as c -> Some (Char.code c - Char.code 'a' + 10)
  | 'A' .. 'F' as c -> Some (Char.code c - Char.code 'A' + 10)
  | _ -> None
;;

let is_unreserved = function
  | ('A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-' | '.' | '_' | '~') as c ->
    Some c
  | _ -> None
;;

let is_path_segment ?(plus_as_space = false) c =
  match is_unreserved c with
  | Some c -> Some c
  | None ->
    (match c with
     | ' ' when plus_as_space -> Some '+'
     | '+' when plus_as_space -> None
     | '!'
     | '$'
     | '&'
     | '\''
     | '('
     | ')'
     | '*'
     | '+'
     | ','
     | ';'
     | '='
     | ':'
     | '@' -> Some c
     | _ -> None)
;;

let is_query_component c =
  match is_unreserved c with
  | Some c -> Some c
  | None ->
    (match c with
     | '!' | '$' | '\'' | '(' | ')' | '*' | ',' | ':' | '@' | '/' | '?' ->
       Some c
     | ' ' -> Some '+'
     | _ -> None)
;;

let encode ~is_allowed s =
  let buf = Buffer.create (String.length s) in
  let () =
    String.iter
      (fun c ->
         match is_allowed c with
         | Some c -> Buffer.add_char buf c
         | None ->
           let code = Char.code c in
           Buffer.add_char buf '%';
           Buffer.add_char buf hex.[code lsr 4];
           Buffer.add_char buf hex.[code land 0x0f])
      s
  in
  Buffer.contents buf
;;

let decode ?(plus_as_space = false) str =
  let len = String.length str in
  let buf = Buffer.create len in
  let rec aux i =
    if i >= len
    then Buffer.contents buf
    else (
      match str.[i] with
      | '%' ->
        if i + 2 >= len
        then (
          (* KLUDGE: We assume that the escape sequence is incorrect and treat the
             percentage as if it hadn’t been escaped. Perhaps we
             should throw an exception? *)
          let () = Buffer.add_char buf '%' in
          aux (i + 1))
        else (
          match unhex str.[i + 1], unhex str.[i + 2] with
          | Some hi, Some lo ->
            let c = Char.unsafe_chr ((hi lsl 4) lor lo) in
            let () = Buffer.add_char buf c in
            aux (i + 3)
          | _ ->
            (* KLUDGE: Same here about the error case. *)
            let () = Buffer.add_char buf '%' in
            aux (i + 1))
      | '+' when plus_as_space ->
        let () = Buffer.add_char buf ' ' in
        aux (i + 1)
      | c ->
        let () = Buffer.add_char buf c in
        aux (i + 1))
  in
  aux 0
;;
