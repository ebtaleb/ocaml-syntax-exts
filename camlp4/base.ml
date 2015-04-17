open Sys

(*let count_lines f =*)
  (*let ff = open_in f in*)
  (*let rec aux i =*)
    (*try*)
      (*let line = input_line ff in*)
      (*aux (i+1)*)
    (*with _ -> i in*)
  (*aux 0;;*)

let cat_file lst =
  let rec aux xs =
    match xs with
    | [] -> ()
    | x::xs -> (print_endline x; aux xs)
  in aux lst;;

let convert_file fn =
  let ff = open_in fn in
  let rec aux () =
    try
      let line = input_line ff in
        line::(aux ())
    with _ -> []
   in aux () ;;

let exec_out s =
  let tmp = "tmp" in
  let code = Sys.command (s ^ "> "^tmp) in
  let lst = convert_file tmp in
  (code,lst);;

let exec_out_print s =
  let tmp = "tmp" in
  let code = Sys.command (s ^ "> "^tmp) in
  let lst = convert_file tmp in
  let _ = List.map (print_endline) lst in
  (code,lst);;

let exec_cmd s =
  let code = Sys.command s in
  code;;

let touch name com =
  let code = Sys.command (com ^ " > "^name) in
  let lst = convert_file name in
  (code,lst);;

let exec_out_app n s =
  let code = Sys.command (s ^ ">> "^n) in
  let lst = convert_file n in
  (code,lst);;

