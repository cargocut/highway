(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Makes it easy to use Highway with
    {{:https://camlworks.github.io/dream/} Dream}. *)

(** {1 Types}

    A few type aliases to simplify the following signatures. *)

type request = Dream.request
type response = Dream.response Dream.promise
type handler = (request, response) Highway.handler
type middleware = (request, response) Highway.middleware
type 'a context = ('a, request, response) Highway.context
type service = (request, response) Highway.service

(** {1 Routing using Highway} *)

(** [dispatch services] describes a middleware that attempts to route
    one of the services in the [services] list (or moves on to the
    next handler). *)
val dispatch : service list -> middleware

(**[handle_dispatch services] is like {!val:dispatch} but as an
   {!type:handler} instead of a {!type:middleware}. *)
val handle_dispatch : service list -> handler

(** {1 Helpers} *)

(** [redirect ?status ?code ?headers ?anchor ?extra_params route args params]
    is an {!type:handler} that performs a redirection. *)
val redirect
  :  ?status:Dream.redirection
  -> ?code:int
  -> ?headers:(string * string) list
  -> ?anchor:string
  -> ?extra_params:(string * string) list
  -> ( 'scope
       , Highway.Method.for_html_links
       , Highway.something
       , 'param
       , 'args )
       Highway.route
  -> 'args Highway.args
  -> 'param
  -> handler

(** [redirect ?status ?code ?headers ?anchor route args params] is an
    {!type:handler} that performs a redirection (without extra
    params). *)
val redirect'
  :  ?status:Dream.redirection
  -> ?code:int
  -> ?headers:(string * string) list
  -> ?anchor:string
  -> ( 'scope
       , Highway.Method.for_html_links
       , 'cstrs
       , 'param
       , 'args )
       Highway.route
  -> 'args Highway.args
  -> 'param
  -> handler
