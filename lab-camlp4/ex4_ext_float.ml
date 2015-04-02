module Id = struct
  let name = "ex3_ext_float"
  let version = "1.0"
end

(* camlp4o ex3_ext_float.cmo test3.ml *)

open Camlp4

module Make (Syntax : Sig.Camlp4Syntax) = struct
  open Sig
  include Syntax

  class ['a] float_subst _loc = object
    inherit Ast.map as super
    method _Loc_t (_ : 'a) = _loc
    method expr =
      function
      | <:expr< ( + ) >> -> <:expr< ( +. ) >>
      | <:expr< ( - ) >> -> <:expr< ( -. ) >>
      | <:expr< ( * ) >> -> <:expr< ( *. ) >>
      | <:expr< ( / ) >> -> <:expr< ( /. ) >>
      | <:expr< $int:i$ >> ->
           let f = (float_of_int(int_of_string i)) 
           in <:expr< $`flo:f$ >>
      | e -> super#expr e
  end;;

  EXTEND Gram
    GLOBAL: expr;

    expr: LEVEL "simple"
    [ [ "Float"; "."; "("; e = SELF; ")" -> 
           (new float_subst _loc)#expr e ]
    ]
    ;
  END
end

let module M = Register.OCamlSyntaxExtension(Id)(Make) in ()


