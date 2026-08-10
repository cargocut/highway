(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type 'k path = ('k, Void.t) Path.t

type ('meth, 'k) route =
  | CONNECT : 'k path -> ([> `CONNECT ], 'k) route
  | DELETE : 'k path -> ([> `DELETE ], 'k) route
  | GET : 'k path -> ([> `GET ], 'k) route
  | HEAD : 'k path -> ([> `HEAD ], 'k) route
  | OPTIONS : 'k path -> ([> `OPTIONS ], 'k) route
  | PATCH : 'k path -> ([> `PATCH ], 'k) route
  | POST : 'k path -> ([> `POST ], 'k) route
  | PUT : 'k path -> ([> `PUT ], 'k) route
  | QUERY : 'k path -> ([> `QUERY ], 'k) route
  | TRACE : 'k path -> ([> `TRACE ], 'k) route

type ('scope, 'meth, 'k) t =
  | Local : ('meth, 'k) route -> ([> `Local ], 'meth, 'k) t
  | Global : string * ('meth, 'k) route -> ([> `Global ], 'meth, 'k) t

let local x = Local x

let global base_url : ([ `Local ], _, _) t -> _ = function
  | Local route -> Global (base_url, route)
;;

let get x = local (GET x)
let post x = local (POST x)
let connect x = local (CONNECT x)
let delete x = local (DELETE x)
let head x = local (HEAD x)
let options x = local (OPTIONS x)
let patch x = local (PATCH x)
let put x = local (PUT x)
let query x = local (QUERY x)
let trace x = local (TRACE x)

let get_path = function
  | CONNECT p
  | DELETE p
  | GET p
  | HEAD p
  | OPTIONS p
  | PATCH p
  | POST p
  | PUT p
  | QUERY p
  | TRACE p -> p
;;

let concat ?(base_url = "") args = base_url ^ "/" ^ String.concat "/" args

let html_href : ([ `Local | `Global ], Method.for_html_links, _) t -> _ =
  fun route args ->
  match route with
  | Local (GET p) -> concat @@ Path.to_list p args
  | Global (base_url, GET p) -> concat ~base_url @@ Path.to_list p args
;;

let html_action : ([ `Local | `Global ], Method.for_html_form, _) t -> _ =
  fun route args ->
  match route with
  | Local (GET p | POST p) -> concat @@ Path.to_list p args
  | Global (base_url, (GET p | POST p)) ->
    concat ~base_url @@ Path.to_list p args
;;

let target route args =
  match route with
  | Local r -> concat @@ Path.to_list (get_path r) args
  | Global (base_url, r) -> concat ~base_url @@ Path.to_list (get_path r) args
;;
