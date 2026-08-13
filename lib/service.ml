(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type ('request, 'response) t =
  | Service :
      { middleware : ('request, 'response) Middleware.t option
      ; route : (Route.local, Method.t, 'cstr, 'param_ty, 'args) Route.t
      ; context : ('ctx, 'request, 'response) Context.t
      ; handler :
          'args Args.t -> 'param_ty -> 'ctx -> ('request, 'response) Handler.t
      }
      -> ('request, 'response) t

let make ?middleware ~context ~route handler =
  Service { middleware; route; context; handler }
;;

let make_simple ?middleware ~route handler =
  make ?middleware ~context:Context.unit ~route (fun args () () req ->
    handler args req)
;;

let dispatch
      ~given_method
      ~given_path
      ~given_query_params
      services
      fallback
      request
  =
  (* TODO: The following implementation is a bit naive, even though it
     may be good enough for now; however, we might want to improve it
     by implementing a Trie. *)
  let rec resume = function
    | [] -> fallback request
    | Service { middleware; route; context; handler } :: others ->
      (match
         Route.extract_values
           ~given_method
           ~given_path
           ~given_query_params
           route
       with
       | Some (args, param) ->
         let f req = context (handler args param) req in
         (match middleware with
          | None -> f request
          | Some m -> (m f) request)
       | None -> resume others)
  in
  resume services
;;
