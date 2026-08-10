> [!WARNING]  
> This project is still **highly experimental**, but we would be
> delighted to receive feedback (but please be careful with
> production).

# highway

> Highway is a simple, framework-agnostic HTTP router. Its goal is to
> provide a highly abstract API based on the concepts of `response`
> and `request` so that it can, broadly speaking, be adapted to any
> framework in the OCaml ecosystem.


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
