(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(* Yet Another Real World Example. *)

type request = { user : string option }

let error code _req = "Error " ^ string_of_int code

module Param = struct
  include Highway.Param

  type pagination =
    { page : int
    ; size : int
    }

  let make_pagination ?(page = 0) ?(size = 10) () = { page; size }

  let lang =
    define
      ~from_query:(fun fields -> Pidgin.Check.(opt fields "lang" string))
      ~to_query:(function
        | None -> []
        | Some lang -> [ "lang", lang ])
  ;;

  let pagination =
    define
      ~from_query:(fun fields ->
        let open Pidgin.Check in
        let+ page = opt fields "page" (int & Int.is_positive)
        and+ size = opt fields "size" (int & Int.is_positive) in
        make_pagination ?page ?size ())
      ~to_query:(fun { page; size } ->
        [ "page", string_of_int page; "size", string_of_int size ])
  ;;

  let string key = from_hole Highway.Hole.string ~key
  let string' key = from_opt_hole Highway.Hole.string ~key
  let bool key = from_hole Highway.Hole.bool ~key
  let bool' key = from_opt_hole Highway.Hole.bool ~key
  let all = lang & pagination
end

type operator =
  | Add
  | Sub
  | Mul
  | Div

let operator () =
  (* Geez, it is sad to have this unit things. *)
  let hole =
    Highway.Hole.make
      ~to_string:(function
        | Add -> "add"
        | Sub -> "sub"
        | Mul -> "mul"
        | Div -> "div")
      ~from_string:(function
        | "add" -> Some Add
        | "sub" -> Some Sub
        | "mul" -> Some Mul
        | "div" -> Some Div
        | _ -> None)
  in
  Highway.Pattern.Hole hole
;;

module Routes = struct
  open Highway.Route
  open Highway.Pattern

  let home = get [] Param.nop
  let hello = get [ s "hello" ] (Param.string' "username")
  let arith = post [ s "arith"; operator (); int; int ] (Param.bool' "negative")
end

module Precond = struct
  let need_user { user } =
    match user with
    | None -> false
    | Some _ -> true
  ;;

  let refuse_user req = not (need_user req)
end

module Ctx = struct
  let need_user handler ({ user } as req) =
    match user with
    | Some x -> handler x req
    | None ->
      (* used with [Precond], it should never happen. *)
      error 401 req
  ;;
end

module Services = struct
  open Highway

  let home_nonauth =
    Service.make
      ~precondition:Precond.refuse_user
      ~context:Context.unit
      ~route:Routes.home
      (fun [] () () _req -> "Hello anonymous")
  ;;

  let home_auth =
    Service.make
      ~precondition:Precond.need_user
      ~context:Ctx.need_user
      ~route:Routes.home
      (fun [] () user _req -> "Hello " ^ user)
  ;;

  let arith =
    Service.make
      ~context:Context.unit
      ~postcondition:(fun [ op; _; y ] _rev _req ->
        (* Not mandatory but just "for the flex" *)
        match op, y with
        | Div, 0 -> false
        | _ -> true)
      ~route:Routes.arith
      (fun [ op; x; y ] rev () { user = _ } ->
         let f, str =
           match op with
           | Add -> ( + ), "+"
           | Sub -> ( - ), "-"
           | Mul -> ( * ), "*"
           | Div -> ( / ), "/"
         in
         let rev =
           match rev with
           | Some true -> true
           | _ -> false
         in
         let result =
           let r = f x y in
           if rev then 0 - r else r
         in
         Format.asprintf
           "%s(%d %s %d = %d)"
           (if rev then "-" else "")
           x
           str
           y
           result)
  ;;
end

open struct end

let cases = "Real World Example", []
