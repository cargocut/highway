(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type 'k path = ('k, Void.t) Path.t

type (+'meth, 'k) route =
  { path : 'k path
  ; meth : 'meth
  }

type global = private Global
type local = private Local

type ('scope, +'meth, 'k) t =
  | Local : ('meth, 'k) route -> (local, 'meth, 'k) t
  | Global : string * ('meth, 'k) route -> (global, 'meth, 'k) t

let local meth path = Local { meth; path }

let global base_url : (local, _, _) t -> _ = function
  | Local route -> Global (base_url, route)
;;

let get x = local `GET x
let post x = local `POST x
let connect x = local `CONNECT x
let delete x = local `DELETE x
let head x = local `HEAD x
let options x = local `OPTIONS x
let patch x = local `PATCH x
let put x = local `PUT x
let query x = local `QUERY x
let trace x = local `TRACE x
let concat ?(base_url = "") args = base_url ^ "/" ^ String.concat "/" args

let html_href : type scope. (scope, Method.for_html_links, _) t -> _ =
  fun route args ->
  match route with
  | Local { meth = `GET; path = p } -> concat @@ Path.to_list p args
  | Global (base_url, { meth = `GET; path = p }) ->
    concat ~base_url @@ Path.to_list p args
;;

let html_action : type scope. (scope, Method.for_html_form, _) t -> _ =
  fun route args ->
  match route with
  | Local { meth = `GET | `POST; path = p } -> concat @@ Path.to_list p args
  | Global (base_url, { meth = `GET | `POST; path = p }) ->
    concat ~base_url @@ Path.to_list p args
;;

let target : type scope. (scope, _, _) t -> _ =
  fun route args ->
  match route with
  | Local { path = p; _ } -> concat @@ Path.to_list p args
  | Global (base_url, { path = p; _ }) ->
    concat ~base_url @@ Path.to_list p args
;;

let base_url = function
  | Global (x, _) -> x
;;
