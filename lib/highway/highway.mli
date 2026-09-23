(* Copyright (c) 2026, Cargocut and the Highway developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** Highway is a simple, framework-agnostic HTTP router. Its goal is
    to provide a highly abstract API based on the concepts of
    [response] and [request] so that it can, broadly speaking, be
    (probably) adapted to any framework in the OCaml ecosystem. *)

(** {1 Big Picture}

    The library allows you to define typed routes, enabling you to
    generate links using an API similar to the
    {{:https://ocaml.org/manual/5.5/api/Format.html} Format module},
    and to attach controllers to them, similar to the
    {{:https://ocaml.org/manual/5.5/api/Scanf.html} Scanf} module.

    Highway is primarily used to describe {!type:route} and associate
    them with {{!type:service} services}.

    {@ocaml[
    # open Highway ;;
    ]}

    {2 Describing routes}

    To begin with, Highway provides a DSL for describing routes: the
    combination of an HTTP method, a path and a set of query
    parameters. For now, we won’t concern ourselves with query
    parameters.

    Let's define a set of routes:

    {@ocaml[
    # module Routes = struct
        let home = get [] ignore_params
        let hello = get [s "hello"] ignore_params
        let hello_to = get [s "hello"; string] ignore_params
      end ;;
    module Routes :
      sig
        val home : (local, [> `GET ], something, unit, Void.t) route
        val hello : (local, [> `GET ], something, unit, Void.t) route
        val hello_to :
          (local, [> `GET ], something, unit, string -> Void.t) route
      end
    ]}

    As you can see, road types contain a lot of information:

    - [scope] (can be [local] or [global]), that describe the scope of
      a route. If it is [local], it refers to a route that is "internal"
      to the application, and later, it can be associated with a
      service. If the route is global, it is associated with a domain
      and is external to the application (and therefore cannot be
      associated with a service).

    - [met], describes the HTTP method of the route. This tracking is
      useful because it allows you, for example, to prevent certain
      link-generation functions from being used on specific routes. (For
      example, {!val:html_href}, which generates a link usable for [<a>]
      tags, works only for routes associated with the [GET] method).

    - [constraints] Specifies whether the route disallows query
      parameters (the router will continuously reject requests
      containing query parameters). It can have two values: [something],
      which allows query parameters, and [nothing], which disallows
      query parameters.

    - [param_type] the type of all (valid) query parameters. If the
      constraint is [nothing], it will always be [unit]. Here, in our
      examples, we ignore the query parameters (we don't prohibit them),
      but their value is also [unit].

    - [path_params] describes a function that returns [void]
      parameters extracted from the route path.

    Here is an other example with a lot of path parameters (and
    prohibiting query parameters):

    {@ocaml[
    # post
        [int; string; float; bool; s "foo"; s "bar"; int]
        discard_params ;;
    - : (local, [> `POST ], nothing, unit,
         int -> string -> float -> bool -> int -> Void.t)
        route
    = <abstr>
    ]}

    You can define your own hole using {!module:Hole} and
    {!module:Pattern}.

    {3 Computing links from routes}

    The separation of a route's definition from its association with a
    service is heavily inspired by {{:https://ocsigen.org/}
    Ocsigen/Eliom}; it allows routes to be used within services to
    describe connections between different services (and to manage
    form actions).

    Link generation is based on three functions:

    - {!val:html_href} which generates a link to be used in a [<a>]
      tag for the [href] attribute (among others), and this function
      only applies to [GET] routes.

    - {!val:html_action} which generates a link to be used in a
      [<form>] tag for the [method] attribute (among others), and this
      function only applies to [GET] and [POST] routes.

    - {!val:target} which generates the arbitrary route link (which
      can be used, for example, to implement an ambitious
      {{:https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API}
      fetch} function).

    These three functions fill in the gaps in the routes described by
    the [path] and the [query params], and allow you to associate
    additional query parameters (using the [extra_params] parameter,
    it is useful since a service can extract other query params after
    the routing, for example) and an optional anchor (using the
    [anchor] parameter).

    Functions have "quoted images", which reject extra parameters
    (traditional functions require routes with [something] as a
    constraint).

    Here is some example of generating links for routes:

    {@ocaml[
    # html_href Routes.home [] ();;
    - : string = "/"
    ]}

    {@ocaml[
        # html_href Routes.hello [] ();;
        - : string = "/hello"
    ]}

    {@ocaml[
        # html_href Routes.hello_to ["Xavier"] ();;
        - : string = "/hello/Xavier"
    ]}

    And with extra parameters and anchor:

    {@ocaml[
        # html_href
             ~extra_params:["foo", "true"; "bar", "hello"]
             ~anchor:"top-content"
             Routes.hello_to ["Xavier"] ();;
        - : string = "/hello/Xavier?foo=true&bar=hello#top-content"
    ]}

    Or here's a broader example that illustrates the heterogeneous
    nature of {!type:args}:

    {@ocaml[
    let a_route =
      post
        [ int; string; float; bool; s "foo"; s "bar"; int; s "a-long-url" ]
        discard_params
    ;;
    ]}

    If we use {!val:html_action'} since it is a [POST] route that
    disallows query params. First, we can see the error if we did not
    give a proper list of path fragment. The error indicates that the
    list ends prematurely and that some fragments are missing during
    compilation.

    {@ocaml[
    # html_action'
        a_route
        [42; "foo"; 3.14; false; 42]
        ~anchor:"a-specific-part-of-the-document"
        () ;;
    - : string =
    "/42/foo/3.14/false/foo/bar/42/a-long-url#a-specific-part-of-the-document"
    ]}

    {3 Query Params}

    Even though query parameters can be used within the body of a
    service, it is sometimes convenient to extract some of them
    directly during the routing phase so they can be used immediately
    in the body of a service. That is why a route description allows
    you to define a strategy for extracting query parameters.

    Since Highway makes no assumptions about the framework being used,
    the library assumes that query parameters are represented as an
    associative list of [string * string]. So, for example, the
    following query string: [?foo=bar&x=10&foo=message] produces the
    following list:

    {@ocaml[
    [ "foo", "bar"; "x", "10"; "foo", "message" ]
    ]}

    That is the choice {{:https://camlworks.github.io/dream/} Dream}
    has made. However, if you are using a framework that makes a
    different choice — such as {{:https://ocaml.org/p/uri/latest}
    Uri}'s, which uses an associative list of [string * string list] —
    you can use the {!val:Param.from_nested_list} function to convert
    to that representation.

    Unlike {!type:path} fragments, where order matters, we'd like to
    be able to process query parameters independently. To do this, the
    {!type:param} type defines a validation rule on a set of query
    parameters to produce a specific value.

    Behind the scenes, validation uses the
    {{:https://ocaml.org/p/pidgin/1.0.0/doc/pidgin/Pidgin/Check/index.html}
    Pidgin library} to validate query parameters as if they were
    records. By using the {!val:make_params} function, you can define
    a query parameter validator. As for {!type:pattern}, you need to
    give a validation function and a projection function (for link
    generation).

    {4 An example}

    Let's imagine we want to describe a filtering strategy by author
    and category:

    {eof@ocaml[
    module Filter = struct
      type t =
        { author : string
        ; category : string
        ; limit : int option
        }

      let param =
           make_params
             ~from_query:(fun fields ->
               let open Pidgin.Check in
               let+ author = req fields "author" string
               and+ category = req fields "category" string
               and+ limit = opt fields "limit" (int & Int.is_positive) in
               { author; category; limit })
             ~to_query:(fun { author; category; limit } ->
               let all = [ "author", author; "category", category ] in
               match limit with
               | None -> all
               | Some x -> ("limit", string_of_int x) :: all)
               (* This is just for testing reason, you do not need, obviously,
                  to disable ocamlformat here... *)
               [@@ocamlformat "disable"]
    end
    ]eof}

    We define [from_query], which uses a Pidgin record validator (you
    can use the full Pidgin API for making fine-grained validators),
    and a [to_query] function that returns an associative array. (We
    do not return a Pidgin expression because that would be too
    expressive for query parameters.)

    Now, we can define a route that will use the filter:

    {@ocaml[
    let another_route = get [ s "books"; s "filter" ] Filter.param
    ]}

    And when we try to generate the corresponding link:

    {@ocaml[
    # html_href another_route []
         {author = "John Doe"; category = "Novel"; limit = None} ;;
    - : string = "/books/filter?author=John%20Doe&category=Novel"
    ]}

    {@ocaml[
    # html_href another_route []
         {author = "John Doe"; category = "Novel"; limit = Some 42} ;;
    - : string = "/books/filter?limit=42&author=John%20Doe&category=Novel"
    ]}

    And during the routing phase, query parameters will be validated
    and given to the controller.

    {4 Simple API}

    Although the manual definition of a validator is very flexible and
    allows you to describe a wide variety of scenarios, sometimes you
    might want a more direct and straightforward approach. For that,
    there is a slightly simpler (and composable) API available.

    In fact, there are functions that allow you to process query
    parameters one by one, for example:

    - {!val:string_param} which takes a string as an argument—the
      key—and checks whether a string associated with the given key
      exists.

    - {!val:string_opt_param} which takes a string as an argument—the
      key—and checks whether a string associated with the given key
      exists (and wrap it into an option).

    - along with {!val:int_param}, {!val:float_param},
      {!val:char_param}, {!val:bool_param}.

    - and {!val:int_opt_param}, {!val:float_opt_param},
      {!val:char_opt_param}, {!val:bool_opt_param}.

    By default, these validators support only one query parameter, for
    example:

    {@ocaml[
      # html_href
         (get [ s "books"; s "filter" ] (string_param "author"))
         [] "Xavier" ;;
      - : string = "/books/filter?author=Xavier"
    ]}

    However, using the [&] operator, they can be combined. In fact,
    [&] composes two arbitrary validators. For example, the original
    example could be reproduced only in this way:

    {@ocaml[
      # html_href
         (get [ s "books"; s "filter" ]
         (string_param "author"
            & string_param "category"
            & int_opt_param "limit"))
         [] ("Xavier", ("novel", Some 43)) ;;
      - : string = "/books/filter?author=Xavier&category=novel&limit=43"
    ]}

    Similarly, there is [/] that uses [Either] to construct a sum.

    {3 External routes}

    In our view, route description tools provide a robust and
    well-defined approach to describing access points to resources. It
    would therefore be a shame to limit ourselves to internal links.

    Fortunately, the {!val:global} function allows you to convert a
    local route into a global route. For example, here is a very
    small, minimalist (and partial) binding for the
    {{:https://jsonplaceholder.typicode.com/} JsonPlaceholder} API:

    {@ocaml[
    module Json_api = struct
      open Highway

      let base_url = "https://jsonplaceholder.typicode.com"

      let all_posts =
        global base_url (get [ s "posts" ] ignore_params)

      let one_post =
        global base_url (get [ s "posts"; int ] ignore_params)

      let one_post_with_comments =
        global base_url (get [ s "posts"; int; s "comments" ] ignore_params)

      let comments =
        global base_url (get [ s "comments" ] (int_opt_param "postId"))

    end
    (* This is just for testing reason, you do not need, obviously,
       to disable ocamlformat here... *)
    [@@ocamlformat "disable"]
    ]}

    You {b cannot} associate global routes with services (which makes
    sense), but you can still use them to generate links:

    {@ocaml[
    # [ html_href Json_api.all_posts [] ()
      ; html_href Json_api.one_post [1] ()
      ; html_href Json_api.one_post_with_comments [1] ()
      ; html_href Json_api.comments [] None
      ; html_href Json_api.comments [] (Some 1)
      ] ;;
    - : string list =
    ["https://jsonplaceholder.typicode.com/posts";
     "https://jsonplaceholder.typicode.com/posts/1";
     "https://jsonplaceholder.typicode.com/posts/1/comments";
     "https://jsonplaceholder.typicode.com/comments";
     "https://jsonplaceholder.typicode.com/comments?postId=1"]
    ]}

    There is therefore no particular reason not to describe your
    external endpoints using this API, which provides typed functions.

    {2 Describing services}

    Now that we’ve looked at routes, let’s see how to associate
    behaviour with them. In other words, how to associate a controller
    with a route. In Highway terminology (also inspired by
    {{:https://ocsigen.org} Ocsigen}), this involves describing a
    {!type:service}.

    Creating a service is done using the {!val:service} function:

    {@ocaml[
    # service ;;
    - : ?middleware:('request, 'response) middleware ->
        ?precondition:('request -> bool) ->
        ?postcondition:('args args -> 'param_ty -> 'request -> bool) ->
        context:('ctx, 'request, 'response) context ->
        route:(local, meth, 'cstr, 'param_ty, 'args) route ->
        ('args args -> 'param_ty -> 'ctx -> ('request, 'response) handler) ->
        ('request, 'response) service
    = <fun>
    ]}

    For now, we won’t worry about the specific settings; we’ll get
    straight to the point by using a pre-configured version of
    [service]:

    {@ocaml[
    # let simple_service ~route handler =
        service ~context:no_context ~route handler ;;
    val simple_service :
      route:(local, meth, 'a, 'b, 'c) route ->
      ('c args -> 'b -> unit -> ('d, 'e) handler) -> ('d, 'e) service = <fun>
    ]}

    So the main idea of [Services] is to associate a {!type:route}
    with an handler. As we can see in the signature of
    [simple_service], a handler is a function that takes the following
    form:

    {@ocaml skip[
    fun [ args_from_route_path ] query_parameter context request -> a_response
    ]}

    Here, since our [simple_service] is fixed to {!val:no_context} the
    [context] parameter will be [unit].

    As we have said on numerous occasions, Highway is HTTP
    server-agnostic, so for the purposes of this tutorial, let’s
    assume that a [response] is a [string] and define a dummy
    [request] type, and let’s create our first service:

    {@ocaml[
    type request =
      { user : string option
      ; query : (string * string) list
      }

    let req ?user ?(query = []) () = { user; query }
    ]}

    {@ocaml[
    let a_first_service =
      simple_service ~route:Routes.home (fun [] () () _req ->
        "Welcome to my website")
    ;;
    ]}

    Let's write an other service with a more complicated route:

    {@ocaml[
    let an_other_service =
      simple_service ~route:Routes.hello_to (fun [ name ] () () _req ->
        "Hello world, Hello" ^ name)
    ;;
    ]}

    And let’s write one final service that utilises query parameters:

    {@ocaml[
    let yet_another_service =
      simple_service
        ~route:another_route
        (fun [] { author; category; limit } () _req ->
           [ "Author: " ^ author
           ; "Category: " ^ category
           ; ("Limit: "
              ^ Option.(value ~default:"none" (map string_of_int limit)))
           ]
           |> String.concat "\n")
    ;;
    ]}

    As we can see, the callback function – the handler – is heavily
    dependent on the route. This allows us to be guided by the type
    system.

    {3 Middleware}

    A {!type:middleware} is a composable function that wraps a web
    handler to process a request before it reaches the handler and/or
    a response after it returns. They can provide capabilities, guards
    etc.

    They are applied once routing has been completed (and therefore do
    not allow the user to proceed to the next page). Let’s imagine,
    for example, that we want to have services that are only
    accessible if the user is logged in:

    {@ocaml[
    (* An helper for errors *)
    let error_response ?message code _req =
      "Error "
      ^ string_of_int code
      ^
      match message with
      | None -> ""
      | Some message -> "\n" ^ message
    ;;

    let user_required next_handler ({ user; _ } as req) =
      match user with
      | None -> error_response ~message:"You need to be logged" 401 req
      | Some _ -> next_handler req
    ;;
    ]}

    Now, our function is a {!type:middleware}; if the user is present
    in the request, the programme continues; otherwise, an error
    response is returned. We can now use it in a service definition:

    {@ocaml[
    let yet_another_service =
      service
        ~middleware:user_required
        ~context:no_context
        ~route:another_route
        (fun [] { author; category; limit } () _req ->
           [ "Author: " ^ author
           ; "Category: " ^ category
           ; ("Limit: "
              ^ Option.(value ~default:"none" (map string_of_int limit)))
           ]
           |> String.concat "\n")
    ;;
    ]}

    Now, if the service is running but the user is not logged in, the
    application will return an error response. It is possible to
    combine several middleware components sequentially using
    {!val:middleware_list}.

    {3 Context}

    A {!type:context} is a “type of middleware” that is applied and
    allows you to retrieve a value to pass to the handler
    function. For example, if instead of just verifying, via
    middleware, that a user is registered (using our test request), we
    also want to “pass it to our controller,” we could describe a
    context provider this way:

    {@ocaml[
    let provide_user handler ({ user; _ } as req) =
      match user with
      | None -> error_response ~message:"You need to be logged" 401 req
      | Some user -> handler user req
    ;;
    ]}

    It's roughly the same as our [user_required] middleware, except
    that this time, the user is “sent” to the next handler (which is
    our service's controller), which will change the nature of the
    [slot] (previously [()]) located between the query parameter and
    the request..

    {@ocaml[
    let yet_another_service =
      service
        ~middleware:user_required
        ~context:provide_user
        ~route:another_route
        (fun [] { author; category; limit } provided_user _req ->
           [ "Author: " ^ author
           ; "Category: " ^ category
           ; ("Limit: "
              ^ Option.(value ~default:"none" (map string_of_int limit)))
           ; "Hello " ^ provided_user
           ]
           |> String.concat "\n")
    ;;
    ]}

    If you don't need context, you can simply use the
    {!val:no_context} function, which returns [unit] as the context
    (as in our definition of [simple_service]).

    {3 Conditions}

    In addition, a service can “hold” two conditions: [precondition]
    and [postcondition], which are two functions that return Boolean
    values. If either of these functions returns [false], the router
    moves on to analyzing the route for the next service. The
    conditions therefore allow the router to skip the route currently
    being analyzed during the routing process.

    This is convenient because once a service has booted (i.e., once
    it has been selected in the routing), it is not possible to move
    on to the next route from the controller—but why are there two
    levels of conditions?

    - [precondition] is a function ['request -> bool], It takes action
      immediately after verifying that the methods match, which is why
      it uses only the [request] as the subject of observation.

    - [postcondition] is a function
      ['args args -> 'param -> 'request -> bool] It runs after the
      {!type:path} fragments have been parsed
      and after the query parameters have been validated. It provides
      additional context to help determine whether to validate the
      route. It runs immediately before the middleware (and the context)
      are applied.

    By default, both conditions always evaluate to [true].

    {2 Performing routing}

    Now that we've seen how to describe {!type:route} and
    {!type:service} (and how to constrain them using
    {!type:middleware}, {!type:context}, and conditions), we'll take a
    broad look at how routing works.

    To route, we use the {!val:dispatch} function, which has the
    following type:

    {@ocaml[
    # let dispatch = Service.dispatch ;;
    val dispatch :
      given_method:meth ->
      given_path:string list ->
      given_query_params:(string * string) list ->
      ('a, 'b) service list -> ('a, 'b) middleware = <fun>
    ]}

    For reasons of generality (once again), the function assumes that
    query parameters have been normalized as described in the previous
    sections and that the path is a list of strings; for example,
    [a/b/foo] becomes [[“a”; ‘b’; “foo”]]. It then takes a list of
    services as an argument and returns a {!type:middleware}. In other
    words, if the function doesn't find a route, it passes control to
    the next handler (which could be another piece of middleware).

    {3 Analysis of a candidate service}

    Here is a general overview of how the router determines whether a
    service is a candidate or not:

    - Checks whether the service's method is the same as the one
      provided by [given_method].
    - Checks the [precondition].
    - Checks the {!type:path} using [given_path] (and extract path
      values into an {!type:args}).
    - Checks the {!type:param} using [given_query_params].
    - Checks the [postcondition].

    At this stage, the service is validated as a result and the router
    apply middleware and context:

    - Apply the [context] of the service.
    - Apply the [middleware] (if it exists).

    {b At this time, Highway does not “intelligently” sort service
    routes.}

    There you go—you've just gotten a quick overview of the various
    features offered by Highway, just like a {b generic router}. Here
    is the full API. *)

(** {1 Types}

    Re-exporting utility types to simplify the API. *)

(** [args] type describes a heterogeneous list used to generate links
    associated with a route. It can also serve as a controller
    parameter. *)
type 'a args = 'a Args.t

(** [hole] describes an arbitrary value that can be serialized or
    deserialized. They are used to describe route patterns that
    introduce variables. *)
type 'a hole = 'a Hole.t

(** [pattern] is a path fragment. It can be either a constant value
    (using the {!val:s} function) or a placeholder that introduces a
    variable (using {!type:hole}) into the path. *)
type ('a, 'b) pattern = ('a, 'b) Pattern.t

(** [path] is a heterogeneous list of {{!type:pattern} patterns}
    (which introduces holes in the final type signature). *)
type ('a, 'b) path = ('a, 'b) Path.t

(** [meth] describes an
    {{:https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods}
    HTTP method} in a rather simplistic way. Since certain
    capabilities are unlocked by using specific HTTP verbs, the
    representation of methods uses polymorphic variants to allow for
    intersections. *)
type meth = Method.t

(** Describes a set of query parameters
    ({{:https://en.wikipedia.org/wiki/Query_string} parameters in the
    query string}) associated with a validation strategy, as supported
    by the {{:https://ocaml.org/p/pidgin/latest} Pidgin
    library}. ['cstrs] allows you to specify whether you want to
    disallow query parameters (or not); ['ty] is the type to which you
    cast your set of parameters. *)
type ('cstrs, 'ty) param = ('cstrs, 'ty) Param.t

(** Describes the prohibition of parameters. *)
and nothing = Param.nothing

(** Describes the authorization of parameters. *)
and something = Param.something

(** A route is a combination of a scope ({!type:local} or
    {!type:global}), a {{!type:meth} method}, a {{!type:path} path},
    and a {{!type:param} query parameter validator}.

    Routes are the building blocks for creating services (a controller
    associated with a route) and for generating links for given routes
    while adhering to the typing defined by the holes in a path. *)
type ('scope, +'meth, 'cstrs, 'params_ty, 'k) route =
  ('scope, 'meth, 'cstrs, 'params_ty, 'k) Route.t

(** Describes the local scope (inside the application). *)
and local = Route.local

(** Describes the global scope (outside the application). *)
and global = Route.global

(** Describes a function from ['request] to ['response]. *)
type ('request, 'response) handler = ('request, 'response) Handler.t

(** Describes a middleware that extends a given {!type:handler}. *)
type ('request, 'response) middleware = ('request, 'response) Middleware.t

(** Describes a specific handler that passes a context to handlers. *)
type ('ctx, 'request, 'response) context = ('ctx, 'request, 'response) Context.t

(** Describes a service. A controller associated with a route. *)
type ('request, 'response) service = ('request, 'response) Service.t

(** {1 Describing patterns} *)

(** {2 Literal Pattern} *)

(** [s value] describes a {i Literal} pattern, a constant that does
    not introduce a variable into a pattern. *)
val s : string -> ('a, 'a) pattern

(** {2 Hole Pattern}

    You can define your own patterns using {!module:Hole} and
    {!module:Pattern}. *)

(** Describes a pattern that introduces a variable of type
    [string]. *)
val string : (string -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [int]. *)
val int : (int -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [float]. *)
val float : (float -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [char]. *)
val char : (char -> 'a, 'a) pattern

(** Describes a pattern that introduces a variable of type [bool]. *)
val bool : (bool -> 'a, 'a) pattern

(** Describes a potentially empty hole. It use [empty] to define if a
    value is present or not in a route path. *)
val opt : ?empty:string -> 'a hole -> ('a option -> 'b, 'b) pattern

(** {1 Query parameters}

    Allowing query parameters to be taken into account is a
    potentially debatable choice because, unlike the placeholders
    introduced in a route's patterns, the order of the parameters is
    of little importance. For this reason, all parameters observable
    in the router are processed by a parameter validation function.

    You can describe and compose more Query Param description using
    the module {!module:Param}. *)

(** Describes a validator that explicitly rejects all query
    parameters. (Or {!val:Param.nop}) *)
val discard_params : (nothing, unit) param

(** Describes a validator that explicitly ignores all query
    parameters. (Or {!val:Param.lax}) *)
val ignore_params : (something, unit) param

(** {2 Building Param description} *)

(** [make_params ~from_query ~to_query] Creates a query parameter
    validator.

    [from_query] uses a Pidgin record validator and [to_query]
    produces an associative list, where the arrays repeat the
    keys. (Or {!val:Param.define}) *)
val make_params
  :  from_query:((string * Pidgin.Repr.t) list -> 'a Pidgin.Check.record)
  -> to_query:('a -> (string * string) list)
  -> (something, 'a) param

(** Same as {!val:make_params} but use a module. (Or {!val:Param.make}) *)
val make_params'
  :  (module Sigs.AS_PARAM with type t = 'a)
  -> (something, 'a) param

(** {2 From holes}

    For "unique" query parameters, you can use {!module:Hole} to
    describe them "on the fly." *)

(** [param_from_hole ~key hole] define a single param indexed by [key]
    using a {!module:Hole} as validator. *)
val param_from_hole : key:string -> 'a hole -> (something, 'a) param

(** [opt_param_from_hole ~key hole] define a single optional param
    indexed by [key] using a {!module:Hole} as validator. *)
val opt_param_from_hole : key:string -> 'a hole -> (something, 'a option) param

(** {3 Prebuilt params on top of holes}

    A set of pre-built query parameters based on {!module:Hole}. All
    of these parameters take a string (the query parameter key) as an
    argument. *)

(** [string_param key] describes the [key=a_string] parameter. *)
val string_param : string -> (something, string) param

(** [string_opt_param key] describes the optional [key=a_string]
    parameter. *)
val string_opt_param : string -> (something, string option) param

(** [int_param key] describes the [key=an_int] parameter. *)
val int_param : string -> (something, int) param

(** [int_opt_param key] describes the optional [key=an_int]
    parameter. *)
val int_opt_param : string -> (something, int option) param

(** [float_param key] describes the [key=a_float] parameter. *)
val float_param : string -> (something, float) param

(** [float_opt_param key] describes the optional [key=a_float]
    parameter. *)
val float_opt_param : string -> (something, float option) param

(** [char_param key] describes the [key=a_char] parameter. *)
val char_param : string -> (something, char) param

(** [char_opt_param key] describes the optional [key=a_char]
    parameter. *)
val char_opt_param : string -> (something, char option) param

(** [bool_param key] describes the [key=a_bool] parameter. *)
val bool_param : string -> (something, bool) param

(** [bool_opt_param key] describes the optional [key=a_bool]
    parameter. *)
val bool_opt_param : string -> (something, bool option) param

(** {1 Routes} *)

(** {2 Building internal routes} *)

(** [get path] describes a local route, associated to the method [GET]
    for the given [path]. *)
val get
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `GET ], 'cstr, 'param_ty, 'k) route

(** [post path] describes a local route, associated to the method [POST]
    for the given [path]. *)
val post
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `POST ], 'cstr, 'param_ty, 'k) route

(** [connect path] describes a local route, associated to the method [CONNECT]
    for the given [path]. *)
val connect
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `CONNECT ], 'cstr, 'param_ty, 'k) route

(** [delete path] describes a local route, associated to the method [DELETE]
    for the given [path]. *)
val delete
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `DELETE ], 'cstr, 'param_ty, 'k) route

(** [head path] describes a local route, associated to the method [HEAD]
    for the given [path]. *)
val head
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `HEAD ], 'cstr, 'param_ty, 'k) route

(** [options path] describes a local route, associated to the method [OPTIONS]
    for the given [path]. *)
val options
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `OPTIONS ], 'cstr, 'param_ty, 'k) route

(** [patch path] describes a local route, associated to the method [PATCH]
    for the given [path]. *)
val patch
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `PATCH ], 'cstr, 'param_ty, 'k) route

(** [put path] describes a local route, associated to the method [PUT]
    for the given [path]. *)
val put
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `PUT ], 'cstr, 'param_ty, 'k) route

(** [query path] describes a local route, associated to the method [QUERY]
    for the given [path]. *)
val query
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `QUERY ], 'cstr, 'param_ty, 'k) route

(** [trace path] describes a local route, associated to the method [TRACE]
    for the given [path]. *)
val trace
  :  ('k, Void.t) path
  -> ('cstr, 'param_ty) param
  -> (local, [> `TRACE ], 'cstr, 'param_ty, 'k) route

(** {2 Building global routes} *)

(** [global base_url local_route] makes [local_route] a global one. *)
val global
  :  string
  -> (local, 'meth, 'cstr, 'param_ty, 'k) route
  -> (global, 'meth, 'cstr, 'param_ty, 'k) route

(** {2 Link Generation}

    Routes are used to generate links and generally follow this pattern:
    [function ?anchor ?extra_params route args].

    They are backed by quoted versions that prevent extra parameters
    from being passed to routes that do not accept query
    parameters. *)

(** [html_href ?anchor ?extra_params route args param] generates a
    link that can be used in a [<a>] tag for a given [route] (using
    [args] and [param]). The link can be attached to [anchor] and
    [extra_params] *)
val html_href
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, Method.for_html_links, something, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [html_href' ?anchor route args param] same as {!val:html_href} but
    disallow [extra_params] (usable with [nothing] constraint). *)
val html_href'
  :  ?anchor:string
  -> ('scope, Method.for_html_links, 'cstrs, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [html_action ?anchor ?extra_params route args param] generates a
    link that can be used in a [<form action=...>] tag for a given
    [route] (using [args] and [param]). The link can be attached to
    [anchor] and [extra_params] *)
val html_action
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, Method.for_html_form, something, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [html_action' ?anchor route args param] same as {!val:html_action}
    but disallow [extra_params] (usable with [nothing] constraint). *)
val html_action'
  :  ?anchor:string
  -> ('scope, Method.for_html_form, 'cstrs, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [target ?anchor ?extra_params route args] compute a link for a
    given route, without any method constraints (this can be used, for
    example, to create [fetch] calls in JavaScript). *)
val target
  :  ?anchor:string
  -> ?extra_params:(string * string) list
  -> ('scope, 'meth, something, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** [target' ?anchor route args param] same as {!val:target}
    but disallow [extra_params] (usable with [nothing] constraint). *)
val target'
  :  ?anchor:string
  -> ('scope, 'meth, 'cstrs, 'param_ty, 'args) route
  -> 'args args
  -> 'param_ty
  -> string

(** {1 Middleware}

    A middleware is a composable function that wraps a web handler to
    process a request before it reaches the handler and/or a response
    after it returns. *)

(** [middleware_list some_middlware] reduce a list of middleware into
    one, sequentially. It allows to collapse multiple middleware. (or
    {!val:Middleware.fold}) *)
val middleware_list
  :  ('request, 'response) middleware list
  -> ('request, 'response) middleware

(** {1 Context}

    A context is a specific type of middleware that allows data to be
    injected arbitrarily into a service handler associated with a
    route. *)

(** No context, inject [unit] as a context. (or
    {!val:Context.unit}) *)
val no_context : (unit, 'request, 'response) context

(** [value_context x] inject [x] as a context. (or
    {!val:Context.const}) *)
val value_context : 'a -> ('a, 'request, 'response) context

(** {1 Service}

    A service is a controller associated with a route. Along with
    {!type:route}, it is the main component of Highway. *)

(** [service ?middleware ?precondition ?postcondition ~context ~route handler]
    describes a service/controller. (or {!val:Service.make})

    - [middleware] allows you to assign additional middleware to a
      route, which is executed after the route is selected. (You can use
      {!val:middleware_list} to sequentially compose multiple middleware
      components.)

    - [precondition] checks a precondition only if the method matches,
      before proceeding to extract the path and query parameters. If the
      function returns [false], it moves on to the next route. By
      default, the function always returns [true].

    - [postcondition] checks a precondition after the extraction the
      path and query parameters (before the middlware and context
      application). If the function returns [false], it moves on to the
      next route. By default, the function always returns [true].

    - [context] A type of middleware that allows you to provision an
      additional value. To ignore it, use {!val:no_context}.

    - [route] the route of the service. *)
val service
  :  ?middleware:('request, 'response) middleware
  -> ?precondition:('request -> bool)
  -> ?postcondition:('args args -> 'param_ty -> 'request -> bool)
  -> context:('ctx, 'request, 'response) context
  -> route:(local, meth, 'cstr, 'param_ty, 'args) route
  -> ('args args -> 'param_ty -> 'ctx -> ('request, 'response) handler)
  -> ('request, 'response) service

(** {2 Routing services}

    Now that we can describe services, the final step is to choose the
    right service from a given list. *)

(** [dispatch ~given_method ~give_path ~given_query_params services]
    describes a {!type:middleware} that selects a service from a given
    list (or falls back to the next middleware). *)
val dispatch
  :  given_method:meth
  -> given_path:string list
  -> given_query_params:(string * string) list
  -> ('request, 'response) service list
  -> ('request, 'response) middleware

(** {1 Infix}

    A set of infix operators to simplify the use and composition of
    some Highway objects. *)

module Infix : sig
  (** Infix operators *)

  (** [tl1 ++ tl2] is [Path.append tl2 tl2], see
      {!val:Path.append}. *)
  val ( ++ ) : ('a, 'b) path -> ('b, 'c) path -> ('a, 'c) path

  (** [param_a & param_b] compose the product of two query params. *)
  val ( & )
    :  (something, 'ty_a) param
    -> (something, 'ty_b) param
    -> (something, 'ty_a * 'ty_b) param

  (** [param_a / param_b] compose the sum of two query params. *)
  val ( / )
    :  (something, 'ty_a) param
    -> (something, 'ty_b) param
    -> (something, ('ty_a, 'ty_b) Either.t) param
end

include module type of Infix (** @inline *)

(** {1 Internal modules}

    Re-exporting internal modules (if functions are not re-exported in
    the main module). *)

module Void = Void
module Pct = Pct
module Sigs = Sigs
module Args = Args
module Hole = Hole
module Pattern = Pattern
module Path = Path
module Method = Method
module Route = Route
module Handler = Handler
module Middleware = Middleware
module Context = Context
module Param = Param
module Service = Service
