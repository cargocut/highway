> [!WARNING]  
> This project is still **highly experimental**, but we would be
> delighted to receive feedback (but please be careful with
> production).

# highway

> Highway is a simple, framework-agnostic HTTP router. Its goal is to
> provide a highly abstract API based on the concepts of `response`
> and `request` so that it can, broadly speaking, be adapted to any
> framework in the OCaml ecosystem.

Highway allows you to define typed routes (whose query parameters are
validated by [Pidgin](https://github.com/cargocut/pidgin)) that can:
- be used to generate links in a type-safe manner
- build services (controllers) and route them

```ocaml
open Highway
```

First let's define a few routes:

```ocaml
module Routes = struct
  let home = get [] ignore_params
  let hello = get [ s "hello" ] ignore_params
  let hello_to = get [ s "hello"; string ] (bool_opt_param "shout")
end
```

Next, we'll associate these routes with controllers by defining
services:

```ocaml
module Services = struct
  let a_href route args params message =
    "<a href=\"" ^ html_href route args params ^ "\">" ^ message ^ "</a>"
  ;;

  let home =
    service ~context:no_context ~route:Routes.home (fun [] () () _request ->
      "Welcome to my website. Here is a page: "
      ^ a_href Routes.hello [] () "<button>Hello Page!</button>"
      ^ "and here is another page: "
      ^ a_href
          Routes.hello_to
          [ "Highway" ]
          (Some true)
          "<button>Hello to Highway!</button>")

  let hello =
    service ~context:no_context ~route:Routes.hello (fun [] () () _request ->
      "Hello, World... " ^ a_href Routes.home [] () "Back to home")

  let hello_to =
    service
      ~context:no_context
      ~route:Routes.hello_to
      (fun [ name ] shout () _request ->
         let is_shout = Option.value ~default:false shout in
         let name = if is_shout then String.uppercase_ascii name else name in
         "Hello " ^ name ^ "... " ^ a_href Routes.home [] () "Back to home")
end
```

And now we can route our various services:

```ocaml
let dispatch ~given_method ~given_path ~given_query_params () =
  dispatch
    ~given_method
    ~given_path
    ~given_query_params
    Services.[ home; hello; hello_to ]
```

Please refer to the documentation for the `highway.mli` module for more information.

## Adapters

As mentioned in the introduction, the goal of Highway is to be
agnostic, and thus to be composable with other, more ambitious
libraries. Here is a list of the implemented bindings.

- [Dream](https://camlworks.github.io/dream/#forms): the package
  `highway-dream` provides primitives for using Highway as a router
  (or as middleware) in a Dream application.
  
We hope more adapters will be available soon!


## Acknowledgement

Although it is a rewrite of the [Nightmare
router](https://github.com/funkywork/nightmare), taken from the
[Muhokama](https://github.com/xvw/muhokama) project _itself_,
**Highway** draws heavily on existing projects within the OCaml
community (and would not have been possible without them):

- [Ocsgien](https://ocsigen.org/): the initial inspiration, which
  highlighted the value of advanced use of type systems to build
  complex web applications.
- [Tyre](https://github.com/Drup/tyre): a very similar use of GADTs
  that served as inspiration.
- [Format](https://ocaml.org/manual/5.5/api/Format.html): _routers_
  has a lot in common with the OCaml Format module, which is very well
  documented in the [following
  presentation](https://ocaml.org/conferences/ocaml/2013/slides/vaugon.pdf)
  and embodied by the incredible
  [PR6017](https://github.com/ocaml/ocaml/issues/6017).
- And other community projects like
  [Vif](https://github.com/robur-coop/vif) and
  [Mkernel](https://github.com/robur-coop/mkernel/), that are always
  fun and inspiring to use!

The main idea of using heterogeneous lists rather than continuations
comes primarily from [gr-im](https://github.com/gr-im), likely
inspired by [PR13372](https://github.com/ocaml/ocaml/pull/13372), and
the implementation received **a lot of help** from
[Octachron](https://github.com/Octachron) (_as usual_).
