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
  | Global : ('meth, 'k) route -> ([> `Global ], 'meth, 'k) t

let local x = Local x

let global : ([ `Local ], _, _) t -> _ = function
  | Local route -> Global route
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
