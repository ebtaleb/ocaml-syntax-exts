(* #load "dynlink.cma" *)
(* camlp4 -parser ex2_code_gen.cmo *)

open Camlp4.PreCast

type 'loc expr = String of string * 'loc
                | Var of string * 'loc
type 'loc stmt = Def of string * 'loc expr * 'loc
                | Echo of string * 'loc
                | Wc of 'loc expr * 'loc

let expr = Gram.Entry.mk "expr"
let stmt = Gram.Entry.mk "stmt"
let _loc = Loc.mk "<string>"

EXTEND Gram
expr: [
    [ s = STRING -> String (s,_loc)
    | "$"; "{"; s = LIDENT; "}" -> Var (s,_loc) ] ];
stmt: [
    [ v = LIDENT; "="; e = expr -> Def (v,e,_loc)
    | "echo"; y = STRING -> Echo (y,_loc)
    | "wc"; s = expr -> Wc (s,_loc) ] ];
END ;;

let expr_of_expr = function
    | String (s,_loc) -> <:expr< $str:s$ >>
    | Var (s,_loc) -> <:expr< $lid:s$ >>

let rec generate_code = function
    | Def (v,e,_loc) -> <:str_item< let $lid:v$ = $expr_of_expr e$ ;; >>
    | Echo (es,_loc) -> <:str_item< print_endline $str:es$ ;; >>
    | Wc (Var (es, _),_loc) -> <:str_item< let c = exec_cmd ("wc "^ $lid:es$ ) ;; >>

let parse_and_generate_code str =
  let e = Gram.parse_string stmt _loc str in
  generate_code e

let main =
    let lines = ref [] in
    let chan = open_in "ws0.sh" in
    try
        while true; do
          let str = input_line chan in
          let e = parse_and_generate_code str in
          Camlp4.PreCast.Printers.OCaml.print_implem e
        done
    with End_of_file ->
        close_in chan;
