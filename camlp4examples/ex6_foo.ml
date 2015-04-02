let rec p = parser 
  | [< '"foo"; 'x; '"bar" >] -> "foo-bar+" ^ x 
  | [< '"baz"; y = p >] -> "baz+" ^ y 

