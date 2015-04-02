let rec p = parser 
  | [< x = q >] -> x 
  | [< '"bar" >] -> "bar" 

