open Camlp4.PreCast 
module Gram = MakeGram(Lexer) 
let expr = Gram.Entry.mk "expr" 
EXTEND Gram 
  expr: 
    [[ 
       "foo"; x = LIDENT; "bar" -> "foo-bar+" ^ x 
     | "baz"; y = expr -> "baz+" ^ y 
     ]]; 
END ;; 
try 
  print_endline 
    (Gram.parse_string expr Loc.ghost Sys.argv.(1)) 
with Loc.Exc_located (_, x) -> raise x
