(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type ('request, 'response) t =
  | Service :
      { middleware : ('request, 'response) Middleware.t option
      ; route : (Route.local, Method.t, 'args) Route.t
      ; context :
          ('context -> ('request, 'response) Handler.t)
          -> ('request, 'response) Handler.t
      ; handler : 'args Args.t -> 'context -> ('request, 'response) Handler.t
      }
      -> ('request, 'response) t

let contextual ?middleware ~context ~route handler =
  Service { middleware; route; context; handler }
;;

let simple ?middleware ~route handler =
  contextual ~context:(fun h -> h ()) ?middleware ~route handler
;;

let dispatch ~given_method ~given_path ~fallback services request =
  let rec resume = function
    | [] -> fallback request
    | Service { middleware; route; context; handler } :: others ->
      (match Route.get_args ~given_method ~given_path route with
       | Some args ->
         let f req = context (handler args) req in
         (match middleware with
          | None -> f request
          | Some m -> (m f) request)
       | None -> resume others)
  in
  resume services
;;
