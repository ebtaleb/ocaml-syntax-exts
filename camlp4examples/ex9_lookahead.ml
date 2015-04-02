open Camlp4.PreCast 
module Gram = MakeGram(Lexer) 
let expr = Gram.Entry.mk "expr" 
EXTEND Gram 
  GLOBAL: expr; 
 
  g: [[ "plugh" ]]; 
  f1: [[ g; "quux" ]]; 
  f2: [[ g; "xyzzy" ]]; 
 
  expr: 
    [[ f1 -> "f1" | f2 -> "f2" ]]; 
END;; 
try 
  print_endline 
    (Gram.parse_string expr Loc.ghost Sys.argv.(1)) 
with Loc.Exc_located (_, x) -> raise x

(* plugh quux --> f1 *)
(* plugh xyzzy --> EXCEPTION *)