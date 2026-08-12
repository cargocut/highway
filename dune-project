(lang dune 3.21)
(name highway)
(version dev)
(generate_opam_files)

(source (github cargocut/highway))
(license BSD-3-Clause)

(authors
  "d-plaindoux <d.plaindoux@free.fr>"
  "xhtmlboi <xhtmlboi@gmail.com>"
  "xvw <xaviervdw@gmail.com>"
  "msp <spawnmick@gmail.com>"
  "grm <grimfw@gmail.com>")
(maintainers
  "d-plaindoux <d.plaindoux@free.fr>"
  "xhtmlboi <xhtmlboi@gmail.com>"
  "xvw <xaviervdw@gmail.com>"
  "msp <spawnmick@gmail.com>"
  "grm <grimfw@gmail.com>")

(package
 (name highway)
 (synopsis "A dead-simple agnostic HTTP router")
 (description "A simple framework-agnostic typed HTTP router")
 (depends
  (ocaml (>= 5.0.0))
  (pidgin (>= 1.0.0))
  
  ;; test setup
  (alcotest (and :with-test (>= 1.9.1)))

  ;; dev setup
  (utop :with-dev-setup)
  (ocamlformat :with-dev-setup)
  (ocp-indent :with-dev-setup)
  (merlin :with-dev-setup)
  (ocaml-lsp-server :with-dev-setup)))
 