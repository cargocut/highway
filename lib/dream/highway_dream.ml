(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type request = Dream.request
type response = Dream.response Dream.promise
type handler = (request, response) Highway.handler
type middleware = (request, response) Highway.middleware
type 'a context = ('a, request, response) Highway.context
type service = (request, response) Highway.service

let adapt_method : Dream.method_ -> Highway.meth option = function
  | `Method s ->
    (match String.(trim @@ lowercase_ascii s) with
     | "query" -> Some `QUERY
     | _ -> None)
  | `GET -> Some `GET
  | `POST -> Some `POST
  | `PUT -> Some `PUT
  | `DELETE -> Some `DELETE
  | `HEAD -> Some `HEAD
  | `CONNECT -> Some `CONNECT
  | `OPTIONS -> Some `OPTIONS
  | `TRACE -> Some `TRACE
  | `PATCH -> Some `PATCH
;;

let adapt_target target =
  match String.split_on_char '/' target with
  | "" :: "" :: xs | "" :: xs | xs -> xs
;;

let dispatch services fallback request =
  match adapt_method (Dream.method_ request) with
  | None -> fallback request
  | Some given_method ->
    let given_path = adapt_target (Dream.target request)
    and given_query_params = Dream.all_queries request in
    Highway.Service.dispatch
      ~given_method
      ~given_path
      ~given_query_params
      services
      fallback
      request
;;

let redirect ?status ?code ?headers ?anchor ?extra_params route args param req =
  let target = Highway.html_href ?anchor ?extra_params route args param in
  Dream.redirect ?status ?code ?headers req target
;;

let redirect' ?status ?code ?headers ?anchor route args param req =
  let target = Highway.html_href' ?anchor route args param in
  Dream.redirect ?status ?code ?headers req target
;;
