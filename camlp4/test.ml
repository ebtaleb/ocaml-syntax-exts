(* #load "dynlink.cma" *)
(* camlp4 -parser ex2_code_gen.cmo *)

open Camlp4.PreCast

type t_expr = String of string
                | Var of string
                | Int of string
                | ValArr of string * string

type t_stmt = Echo of t_expr

type t_cmd = Cmd of string
                | VCmd of string * string
                | ACmd of string * t_expr
                | Out of t_stmt
                | VOut of string * string * string
                | LitOut of string
                | VEcho of t_stmt
                | Def of string * t_expr
                | For of string * string * t_cmd
                | ForRange of string * string * string * t_cmd list
                | Concat of string * string * string
                | DefArray of string

let expr = Gram.Entry.mk "expr"
let stmt = Gram.Entry.mk "stmt"
let cmd = Gram.Entry.mk "cmd"
let _loc = Loc.mk "<string>"

EXTEND Gram
stmt: [[
    "array"; "{"; id = LIDENT; "}" -> DefArray id
    (*| "for"; "("; id = LIDENT; ")"; "in"; "("; i1 = INT; i2 = INT; ")"; ":"; stmts = stmt -> ForRange (id, i1, i2, stmts)*)
    | "for"; "("; id = LIDENT; ")"; "in"; "("; i1 = INT; i2 = INT; ")"; ":"; stmts = LIST1 stmt SEP ";" -> ForRange (id, i1, i2, stmts)
    | "for"; "("; id = LIDENT; ")"; "in"; "("; r = STRING ;")"; ":"; stmts = stmt -> For (id, r, stmts)
    | "out"; "{"; s = cmd; "}" -> Out s
    | "out"; "{"; s = STRING; e = expr; "}"; ">"; f = STRING ->
            begin
                match e with
                    String e1 | Var e1 -> VOut (s, e1, f)
            end
    | "out"; "{"; s = STRING; "}" -> LitOut s
    | "cmd"; "{"; s = cmd; "}" ->
            begin
                match s with
                    Echo s1 -> VEcho s
            end
    | "cmd"; "{"; s = STRING; e = expr; "}" ->
            begin
                match e with
                    String e1 | Var e1 -> VCmd (s, e1)
                    | ValArr (id, ind) -> ACmd (s, e)
                    | _ -> failwith "nope"
            end
    | "cmd"; "{"; s = STRING; "}" -> Cmd s
    | "concat"; "{"; lop = LIDENT; "="; rop1 = expr; rop2 = expr; "}" ->
            begin
                match rop1, rop2 with String s1, String s2
                | Var s1, Var s2
                | String s1, Var s2
                | Var s1, String s2 -> Concat(lop, s1, s2)
            end
    | v = LIDENT; "="; e = expr -> Def (v,e)
    ] ] ;
cmd: [[
    "echo"; y = expr -> Echo y
    ] ];
expr: [[
    s = STRING -> String s
    | id = LIDENT ;"{"; ind = LIDENT; "}" ->
            ValArr (id, ind)
            (*begin*)
                (*match e with*)
                    (*String index | Var index | Int index -> ValArr (id, index)*)
                    (*| _ -> assert false*)
            (*end*)

    | i = INT -> Int i
    | "$"; "{"; s = LIDENT; "}" -> Var s
    ] ];
END ;;

let rec translate_stmt = function
    | Cmd s -> <:str_item< let $lid:"_"$ = exec_cmd ($str:s$) ;; >>
    | VCmd (s,e) -> <:str_item< let $lid:"_"$ = exec_out_print ($str:s$ ^ " " ^ ! $lid:e$) ;; >>
    | ACmd (s,e) -> <:str_item< let $lid:"_"$ = exec_out ($str:s$ ^ " " ^ $translate_expr e$) ;; >>
    | VEcho (s) ->  <:str_item< let $lid:"_"$ = $translate_cmd s$ ;; >>
    | Out s -> <:str_item< let $lid:"_"$ = exec_out ($translate_cmd s$) ;; >>
    | LitOut s -> <:str_item< let $lid:"_"$ = exec_out ($str:s$) ;; >>
    | Concat (lo, ro1, ro2) -> <:str_item< $lid:lo$ := ! $lid:ro1$ ^ $lid:ro2$ ;; >>
    | DefArray id -> <:str_item<let $lid:id$ = Array.make 1000 "";;  >>
    | Def (v,e) ->
        begin
            match e with
                Var s | String s -> <:str_item< let $lid:v$ = $lid:"ref"$ $str:s$ ;; >>
                | Int i -> <:str_item< let $lid:v$ = $lid:"ref"$ $int:i$ ;; >>
        end
    | For (i, sit, st) ->
        begin
            match st with VCmd (s, e) ->
                <:str_item< let (_, l) = exec_out ($str:sit$);;
                let $lid:i$ = Array.of_list l;;
                for i = 0 to Array.length $lid:i$ - 1 do exec_cmd ($str:s$ ^ " " ^ $lid:i$.(i)) done;;
                let _ = exec_cmd ("rm tmp");;>>
            | Concat (lo, ro1, ro2) ->
                <:str_item< let (_, l) = exec_out ($str:sit$);;
                let $lid:i$ = Array.of_list l;;
                for i = 0 to Array.length $lid:i$ - 1 do $lid:lo$ := ! $lid:ro1$ ^ (" " ^ $lid:ro2$.(i)); done;;
                let _ = exec_cmd ("rm tmp");;>>
            | VOut (cs, vs, f) ->
                <:str_item< let (_, l) = exec_out ($str:sit$);;
                let $lid:i$ = Array.of_list l;;
                for i = 0 to Array.length $lid:i$ - 1 do exec_out_app ($str:f$) ($str:cs$ ^ " " ^ $lid:vs$.(i)) done;;
                let _ = exec_cmd ("rm tmp");;>>
        end
    | ForRange (i, i1, i2, st) ->
            (*let loop_exp = <:expr< for $lid:i$ = $int:i1$ to $int:i2$ do  >> in*)
            (*let done_exp = <:expr < done;;>> in*)
        begin
            match st with x::xs ->
                begin
            match x with Concat (lo, ro1, ro2) ->
                <:str_item<
                for $lid:i$ = $int:i1$ to $int:i2$ do $lid:lo$ := ! $lid:ro1$ ^ $lid:ro2$.(i) done;;
                let _ = exec_cmd ("rm tmp");;>>
            | ACmd (s,e) -> <:str_item< for $lid:i$ = $int:i1$ to $int:i2$ do exec_out_print ($str:s$ ^ " " ^ $translate_expr e$) done;; >>
            | _ -> failwith "nope2"
                end
        end
and translate_cmd = function
    | Echo (Var es) -> <:expr< $lid:"print_endline"$ $lid:es$ >>
    | Echo (String s) -> <:expr< $lid:"print_endline"$ $str:s$ >>
and translate_expr = function
    | String s -> <:expr< $str:s$ >>
    | Var s -> <:expr< $lid:s$ >>
    | ValArr (id, ind) ->  <:expr< $lid:id$.($lid:ind$) >>

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

