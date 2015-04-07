(* #load "dynlink.cma" *)
(* camlp4 -parser ex2_code_gen.cmo *)

open Camlp4.PreCast

type shell = Echo of string
             | Var of string * string

let expression = Gram.Entry.mk "expression"

  EXTEND Gram
  GLOBAL: expression ;
  expression:
      [ "echo" LEFTA
          [ "echo"; y = STRING -> Echo y ] ];
      (*| "var" LEFTA*)
          (*[ x = STRING; "="; y = STRING -> Var (x, y) ] ];*)
  END

let _loc = Loc.mk "<string>"

let rec generate_code = function
  | Echo s -> <:expr< $str:s$ >>
  (*| Var (x, y) -> <:expr< let $id:x$ in $e$ >>*)

let parse_and_generate_code str =
  let e = Gram.parse_string expression _loc str in
  generate_code e

let main =
    let lines = ref [] in
    let chan = open_in Sys.argv.(3) in
    try
        while true; do
          let str = input_line chan in
          let e = parse_and_generate_code str in
          let ast_e = <:expr< $e$ >> in
          Camlp4.PreCast.Printers.OCaml.print_implem <:str_item< let res = print_endline $ast_e$>>
        done
    with End_of_file ->
        close_in chan;
