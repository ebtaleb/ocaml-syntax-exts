open Asttypes
open Parsetree
open Ast_mapper

open Ast_helper
open Longident

let test_mapper argv =
    { default_mapper with
    expr = fun mapper expr ->
        match expr with
        | { pexp_desc = Pexp_extension ({ txt = "echo"; loc }, pstr)} ->
                begin match pstr with
                |
                  PStr [{ pstr_desc =
                          Pstr_eval ({ pexp_loc  = loc;
                                       pexp_desc = Pexp_constant (Const_string (sym, None))}, _)}] ->
                                           Exp.apply ~loc (Exp.ident ({txt = (Longident.Lident "print_endline"); loc})) ([("", (Exp.constant (Const_string (sym,None))))])

                | _ ->
                    raise (Location.Error (Location.error ~loc "[%echo] accepts a string, e.g. [%echo \"USER\"]"))
                end
        | other -> default_mapper.expr mapper other; }

let () = register "ppx_test" test_mapper

