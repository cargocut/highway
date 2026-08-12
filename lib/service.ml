(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type ('request, 'response) t =
  | Service :
      { middleware : ('request, 'response) Middleware.t option
      ; route : (Route.local, Method.t, 'args) Route.t
      ; on_request : 'request -> ('query_params, unit) result
      ; context : ('ctx, 'request, 'response) Context.t
      ; handler :
          'args Args.t
          -> 'query_params
          -> 'ctx
          -> ('request, 'response) Handler.t
      }
      -> ('request, 'response) t

let make ?middleware ~on_request ~context ~route handler =
  Service { middleware; route; context; handler; on_request }
;;

let dispatch ~given_method ~given_path services fallback request =
  let rec resume = function
    | [] -> fallback request
    | Service { middleware; route; context; handler; on_request } :: others ->
      (match Route.get_args ~given_method ~given_path route with
       | Some args ->
         (match on_request request with
          | Ok s ->
            let f req = context (handler args s) req in
            (match middleware with
             | None -> f request
             | Some m -> (m f) request)
          | Error () -> resume others)
       | None -> resume others)
  in
  resume services
;;
