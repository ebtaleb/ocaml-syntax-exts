module type Error = sig 
    type t 
    exception E of t 
    val to_string : t -> string 
    val print : Format.formatter -> t -> unit 
end 

module Error = 
struct 
  type t = string 
  exception E of string 
  let print = Format.pp_print_string 
  let to_string x = x 
end 

let _ = let module M = Camlp4.ErrorHandler.Register(Error) in () 

 module type Token = sig 
    module Loc : Loc 
  
    type t 
      
    val to_string : t -> string 
    val print : Format.formatter -> t -> unit 
    val match_keyword : string -> t -> bool 
    val extract_string : t -> string 
  
    module Filter : ... (* see below *) 
    module Error : Error 
  end 

 type token = 
    | KEYWORD  of string 
    | NUMBER   of string 
    | STRING   of string 
    | ANTIQUOT of string * string 
    | EOI 
 
  module Token = 
  struct 
    type t = token 
  
    let to_string t = 
      let sf = Printf.sprintf in 
      match t with 
        | KEYWORD s       -> sf "KEYWORD %S" s 
        | NUMBER s        -> sf "NUMBER %s" s 
        | STRING s        -> sf "STRING \"%s\"" s 
        | ANTIQUOT (n, s) -> sf "ANTIQUOT %s: %S" n s 
        | EOI             -> sf "EOI" 
  
    let print ppf x = Format.pp_print_string ppf (to_string x) 
  
    let match_keyword kwd = 
      function 
        | KEYWORD kwd' when kwd = kwd' -> true 
        | _ -> false 
  
    let extract_string = 
      function 
        | KEYWORD s | NUMBER s | STRING s -> s 
        | tok -> 
            invalid_arg 
              ("Cannot extract a string from this token: " ^ 
                 to_string tok) 
 
    module Loc = Camlp4.PreCast.Loc 
    module Error = Error 
    module Filter = ... (* see below *) 
  end 

 module Filter : sig 
    type token_filter = 
      (t * Loc.t) Stream.t -> (t * Loc.t) Stream.t 
 
    type t 
 
    val mk : (string -> bool) -> t 
    val define_filter : t -> (token_filter -> token_filter) -> unit 
    val filter : t -> token_filter 
    val keyword_added : t -> string -> bool -> unit 
    val keyword_removed : t -> string -> unit 
  end; 

  module Filter = 
  struct 
    type token_filter = 
      (t * Loc.t) Stream.t -> (t * Loc.t) Stream.t 
 
    type t = unit 
 
    let mk _ = () 
    let filter _ strm = strm 
    let define_filter _ _ = () 
    let keyword_added _ _ _ = () 
    let keyword_removed _ _ = () 
  end 

module type Lexer = sig 
  module Loc : Loc 
  module Token : Token with module Loc = Loc 
  module Error : Error 
 
  val mk : 
    unit -> 
    (Loc.t -> char Stream.t -> (Token.t * Loc.t) Stream.t) 
end 

let rec token c = lexer 
  | eof -> EOI 
 
  | newline -> next_line c; token c c.lexbuf 
  | blank+ -> token c c.lexbuf 
 
  | '-'? ['0'-'9']+ ('.' ['0'-'9']* )? 
      (('e'|'E')('+'|'-')?(['0'-'9']+))? -> 
        NUMBER (L.utf8_lexeme c.lexbuf) 
 
  | [ "{}[]:," ] | "null" | "true" | "false" -> 
      KEYWORD (L.utf8_lexeme c.lexbuf) 
 
  | '"' -> 
      set_start_loc c; 
      string c c.lexbuf; 
      STRING (get_stored_string c) 
 
  | "$" -> 
      set_start_loc c; 
      c.enc := Ulexing.Latin1; 
      let aq = antiquot c lexbuf in 
      c.enc := Ulexing.Utf8; 
      aq 
 
  | _ -> illegal c 


  open Jq_lexer 
 
  module Gram = Camlp4.PreCast.MakeGram(Jq_lexer) 
 
  ... 
      | n = NUMBER -> Jq_number (float_of_string n) 
