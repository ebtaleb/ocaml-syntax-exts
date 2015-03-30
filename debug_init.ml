let usage = "usage: " ^ Sys.argv.(0) ^ " [options] <filename>"

let file = ref ""

let parse option_flag = 
  (* Read the arguments of command *)
  let _ = Arg.parse option_flag (fun s -> file := s) usage in
  let _ = Debug.read_main () in
  ()

let option_flag = [
   ("-dre", Arg.String (fun s ->
      Debug.z_debug_file:=("$"^s); Debug.z_debug_flag:=true),
   "Shorthand for -debug-regexp")
  ;("-debug", Arg.String (fun s ->
      Debug.z_debug_file:=s; Debug.z_debug_flag:=true),
   "Read from a debug log file")
  ;("-dd", Arg.Set Debug.devel_debug_on,
   "Turn on devel_debug");
] ;;

let () = parse option_flag ;;
