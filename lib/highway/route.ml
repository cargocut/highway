(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type 'k path = ('k, Void.t) Path.t

type (+'meth, 'cstrs, 'query_params, 'k) route =
  { path : 'k path
  ; query_params : ('cstrs, 'query_params) Param.t
  ; meth : 'meth
  }

type global = private Global
type local = private Local

type ('scope, +'meth, 'cstrs, 'query_params, 'k) t =
  | Local :
      ('meth, 'cstrs, 'query_params, 'k) route
      -> (local, 'meth, 'cstrs, 'query_params, 'k) t
  | Global :
      string * ('meth, 'cstrs, 'query_params, 'k) route
      -> (global, 'meth, 'cstrs, 'query_params, 'k) t

let local meth path query_params = Local { meth; path; query_params }

let global base_url : (local, _, _, _, _) t -> _ = function
  | Local route -> Global (base_url, route)
;;

let get x qp = local `GET x qp
let post x qp = local `POST x qp
let connect x qp = local `CONNECT x qp
let delete x qp = local `DELETE x qp
let head x qp = local `HEAD x qp
let options x qp = local `OPTIONS x qp
let patch x qp = local `PATCH x qp
let put x qp = local `PUT x qp
let query x qp = local `QUERY x qp
let trace x qp = local `TRACE x qp

let concat
      ?(base_url = "")
      ?(extra_params = [])
      ?(query_params = [])
      ?anchor
      args
  =
  let qp =
    match query_params, extra_params with
    | [], [] -> None
    | [], xs -> Param.concat_query_params xs
    | xs, ys -> Param.concat_query_params (xs @ ys)
  in
  let qp = Option.fold ~none:"" ~some:(fun x -> "?" ^ x) qp
  and anchor = Option.fold ~none:"" ~some:(fun x -> "#" ^ x) anchor in
  base_url ^ "/" ^ String.concat "/" args ^ qp ^ anchor
;;

let extract_route_compenents : type scope. (scope, _, _, _, _) t -> _ =
  fun route ->
  match route with
  | Local { path = p; query_params; _ } -> None, p, query_params
  | Global (base_url, { path = p; query_params; _ }) ->
    Some base_url, p, query_params
;;

let target' ?anchor route args params =
  let base_url, p, qp = extract_route_compenents route in
  let query_params = Param.to_query_params qp params in
  let args = Path.to_list p args in
  concat ?anchor ?base_url ~query_params args
;;

let target
      ?anchor
      ?extra_params
      (route : (_, _, Param.something, _, _) t)
      args
      params
  =
  let base_url, p, qp = extract_route_compenents route in
  let query_params = Param.to_query_params qp params in
  let args = Path.to_list p args in
  concat ?anchor ?base_url ?extra_params ~query_params args
;;

let html_href'
      ?anchor
      (route : (_, Method.for_html_links, _, _, _) t)
      args
      params
  =
  target' ?anchor route args params
;;

let html_href
      ?anchor
      ?extra_params
      (route : (_, Method.for_html_links, Param.something, _, _) t)
      args
      params
  =
  target ?anchor ?extra_params route args params
;;

let html_action'
      ?anchor
      (route : (_, Method.for_html_form, _, _, _) t)
      args
      params
  =
  target' ?anchor route args params
;;

let html_action
      ?anchor
      ?extra_params
      (route : (_, Method.for_html_form, Param.something, _, _) t)
      args
      params
  =
  target ?anchor ?extra_params route args params
;;

let path : type scope. (scope, _, _, _, _) t -> _ = function
  | Local { path; _ } | Global (_, { path; _ }) -> path
;;

let query_params : type scope. (scope, _, _, _, _) t -> _ = function
  | Local { query_params; _ } | Global (_, { query_params; _ }) -> query_params
;;

let base_url = function
  | Global (x, _) -> x
;;

let has_method : type scope. Method.t -> (scope, _, _, _, _) t -> _ =
  fun given_method -> function
  | Local { meth; _ } | Global (_, { meth; _ }) ->
    Method.equal given_method meth
;;

let extract_values
      ?(decode = false)
      (Local { path; query_params; _ })
      ~given_path
      ~given_query_params
  =
  let ( let* ) = Option.bind in
  let* args = Path.from_list ~decode path given_path in
  let* params = Param.from_query ~decode query_params given_query_params in
  Some (args, params)
;;
