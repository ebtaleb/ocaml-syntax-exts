let x2 = Float.( 3/2 - sqrt (1/3) )
let f x =
  Float.( 
    let pi = acos(-1) in
    x/(2*pi) - x**(2/3)
  )
let _ = print_endline ("Answer is "^(string_of_float (f x2)))
