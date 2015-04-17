open Debug_init
open VarGen
open Gen
open Sys

let count_lines f =
  let ff = open_in f in
  let rec aux i =
    try
      let line = input_line ff in
      aux (i+1)
    with _ -> i in
  aux 0;;

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
  let tmp = "__tmp" in
  let code = Sys.command (s ^ "> "^tmp) in
  let lst = convert_file tmp in
  (code,lst);;

let exec_cmd s =
  let code = Sys.command s in
  code;;

let echo s =
  print_endline s;;

let () = echo "################";;
let () = echo "SOLUTION 1 - listing a bunch of ml files using a Loop";;

let (_, l) = exec_out ("ls *.ml");;
let it = Array.of_list l;;
for i = 0 to Array.length it - 1 do
    exec_cmd ("wc "^ it.(i))
done;;

let _ = exec_cmd ("rm "^"__tmp");;

