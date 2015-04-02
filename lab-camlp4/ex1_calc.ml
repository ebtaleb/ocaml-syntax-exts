(* camlp4 -parser ex1_calc.cmo *)

open Camlp4.PreCast

let expression = Gram.Entry.mk "expression"

EXTEND Gram
GLOBAL: expression ;
expression:
    [ [ x = SELF; "+"; y = SELF -> x + y
    | x = SELF; "-"; y = SELF -> x - y
    | x = SELF; "*"; y = SELF -> x * y
    | x = SELF; "/"; y = SELF -> x / y
    | x = INT -> int_of_string x ] ];
END


let main = 
  let _ = print_string "# " in
  let r = Gram.parse_string expression (Loc.mk "<string>") (read_line()) in
  print_string ("Result is "^(string_of_int r)^"\n")

