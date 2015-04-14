(* #load "dynlink.cma" *)
(* camlp4 -parser ex2_code_gen.cmo *)

open Camlp4.PreCast

type t_expr = String of string
                | Var of string

type t_stmt = Echo of t_expr

type t_cmd = Cmd of string
                | VCmd of string * string
                | Out of t_stmt
                | LitOut of string
                | VEcho of t_stmt
                | Def of string * t_expr
                | For of string * string * t_cmd


let expr = Gram.Entry.mk "expr"
let stmt = Gram.Entry.mk "stmt"
let cmd = Gram.Entry.mk "cmd"
let _loc = Loc.mk "<string>"

EXTEND Gram
stmt: [[
    "for"; "("; id = LIDENT; ")"; "in"; "("; r = STRING ;")"; ":"; stmts = stmt -> For (id, r, stmts)
    | "out"; "{"; s = cmd; "}" -> Out s
    | "out"; "{"; s = STRING; "}" -> LitOut s
    | "cmd"; "{"; s = cmd; "}" -> begin match s with Echo s1 -> VEcho s end
    | "cmd"; "{"; s = STRING; e = expr; "}" -> begin match e with String e1 | Var e1 -> VCmd (s, e1) end
    | "cmd"; "{"; s = STRING; "}" -> Cmd s
    | v = LIDENT; "="; e = expr -> Def (v,e)

    ] ] ;
cmd: [[
    "echo"; y = expr -> Echo y
    ] ];
expr: [[
    s = STRING -> String s
    | "$"; "{"; s = LIDENT; "}" -> Var s
    ] ];
END ;;

let rec translate_stmt = function
    | Cmd s -> <:str_item< let $lid:"_"$ = exec_cmd ($str:s$) ;; >>
    | VCmd (s,e) -> <:str_item< let $lid:"_"$ = exec_out ($str:s$ ^ $lid:e$) ;; >>
    | VEcho (s) ->  <:str_item< let $lid:"_"$ = $translate_cmd s$ ;; >>
    | Out s -> <:str_item< let $lid:"_"$ = exec_out ($translate_cmd s$) ;; >>
    | LitOut s -> <:str_item< let $lid:"_"$ = exec_out ($str:s$) ;; >>
    | Def (v,e) -> <:str_item< let $lid:v$ = $translate_expr e$ ;; >>
    | For (i, s, st) -> begin match st with VCmd (s, e) ->
            <:str_item< let (_, l) = exec_out ($str:s$);;
        let $lid:i$ = Array.of_list l;;
        for i = 0 to Array.length $lid:i$ - 1 do exec_cmd ($str:s$ ^ " " ^ $lid:i$.(i)) done;;
        let _ = exec_cmd ("rm "^"__tmp");;>> end

and translate_cmd = function
    | Echo (Var es) -> <:expr< $lid:"print_endline"$ $lid:es$ >>
    | Echo (String s) -> <:expr< $lid:"print_endline"$ $str:s$ >>
and translate_expr = function
    | String s -> <:expr< $str:s$ >>
    | Var s -> <:expr< $lid:s$ >>

let parse_and_generate_code str =
  let e = Gram.parse_string stmt _loc str in
  translate_stmt e;;

let main =
    let chan = open_in Sys.argv.(1) in
    try
        while true; do
          let str = input_line chan in
          let e = parse_and_generate_code str in
          Camlp4.PreCast.Printers.OCaml.print_implem e
        done
    with End_of_file ->
        close_in chan;;

