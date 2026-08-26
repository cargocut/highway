(lang dune 3.21)
(name highway)
(version dev)
(using mdx 0.4)
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
  (ocaml (>= 4.08.0))
  (pidgin (>= 1.0.0))
  
  ;; test setup
  (alcotest (and :with-test (>= 1.9.1)))
  (mdx (and :with-test  (>= 2.6.0)))

  ;; dev setup
  (utop :with-dev-setup)
  (ocamlformat :with-dev-setup)
  (ocp-indent :with-dev-setup)
  (merlin :with-dev-setup)
  (ocaml-lsp-server :with-dev-setup)))

(package
 (name highway-dream)
 (synopsis "Use Highway withing Dream Application")
 (description "Use Highway withing Dream Application")
 (depends
  (ocaml (>= 4.08.0))
  (highway (= :version))
  (dream (>= 1.0.0~alpha8))
  (alcotest (and :with-test (>= 1.9.1)))
  (mdx (and :with-test  (>= 2.6.0)))))