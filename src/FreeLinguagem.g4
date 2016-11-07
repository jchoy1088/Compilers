grammar FreeLinguagem ;

@header {
import java.util.*;
import types.*;
}

@members {
	List<String> symbolTable = new ArrayList<String>();
	Type typ = new Type();
}

WS
	: [ \r\t\u000C\n]+ -> channel(HIDDEN) ;

COMMENT
	: '//' ~('\n'|'\r')* '\r'? '\n' -> channel(HIDDEN) ;

program
	: fdecls maindecl {
	    	System.out.println("Parseou um programa!");
	}
	;

fdecls
	: fdecl fdecls                                   #fdecls_one_decl_rule
	| #fdecls_end_rule ;

maindecl
	: 'def' 'main' '=' funcbody                  #programmain_rule ;

fdecl
	: 'def' functionname fdeclparams '=' funcbody   #funcdef_rule
        /*{
            System.Console.WriteLine("Achou declaração: {0} com {1}", $functionname.text, $fdeclparams.plist.ToString());
        }*/ ;

fdeclparams
returns [List<String> plist]
@ init {
    $plist = new ArrayList<String>();
}
@ after {
    for (String s : $plist) {
        System.out.println("Parametro: " + s);
    }
}
	: fdeclparam {
            $plist.add($fdeclparam.pname);
	}
	fdeclparams_cont[$plist]
      	#fdeclparams_one_param_rule
	|
		#fdeclparams_no_params ;

fdeclparams_cont
[List<String> plist]
	: ',' fdeclparam {
            $plist.add($fdeclparam.pname);
	}
	fdeclparams_cont[$plist]
       #fdeclparams_cont_rule
	| #fdeclparams_end_rule ;

fdeclparam
    returns [String pname, String ptype]
	: symbol ':' type {
            $pname = $symbol.text;
            $ptype = $type.text;
	}
																		        #fdecl_param_rule ;
functionname
	: TOK_ID                                 #fdecl_funcname_rule ;

type
	: basic_type 																		        #basictype_rule
	| sequence_type {
            System.out.println("Variavel do tipo " + $sequence_type.base + " dimensao "+ $sequence_type.dimension);

	}
	#sequencetype_rule ;

basic_type
    returns [String bt]
	: 'i' {
            $bt = typ.TypeInteger();
	}
	| 'b' {
            $bt = typ.TypeBoolean();
	}
	| 's' {
            $bt = typ.TypeString();
	}
	| 'f' {
            $bt = typ.TypeFloat();
	}
	| 'c' {
   			$bt = typ.TypeChar();
	}
	;
sequence_type
returns [int dimension=0, String base]
	: basic_type '[]' {
            $dimension = 1;
            $base = $basic_type.text;
	}																		                                                     #sequencetype_basetype_rule
	| s=sequence_type '[]' {
            $dimension = $s.dimension + 1;
            $base = $s.base;
	}
																		                                                     #sequencetype_sequence_rule ;
funcbody
    returns[Object obj]
	: ifexpr                                       #fbody_if_rule
	| letexpr                                      #fbody_let_rule
	| m = metaexpr
	{
		if($m.me != null){
            if( $m.me.equals("i"))
            {
                System.out.println("==============>Expressao inteira<==============");
            }
            if( $m.me.equals("f"))
            {
                System.out.println("==============>Expressao float<================");
            }
            if( $m.me.equals("s"))
            {
                System.out.println("==============>Expressao string<===============");
            }
            if( $m.me.equals("b"))
            {
                System.out.println("==============>Expressao booleana<=============");
            }
       }
	}
		#fbody_expr_rule
		;

ifexpr
	: 'if' funcbody 'then' funcbody 'else' funcbody  #ifexpression_rule ;

letexpr
	: 'let' letlist 'in' funcbody                    #letexpression_rule ;

letlist
	: letvarexpr  letlist_cont                       #letlist_rule ;

letlist_cont
	: ',' letvarexpr letlist_cont                    #letlist_cont_rule
	| #letlist_cont_end ;

letvarexpr
	: symbol '=' funcbody                         #letvarattr_rule
	| '_'    '=' funcbody                         #letvarresult_ignore_rule
	| symbol '::' symbol '=' funcbody             #letunpack_rule ;

metaexpr
    returns [String me]
	: '(' funcbody ')'
	{
    	System.out.println("Utilizando parentesis");
	}
		#me_exprparens_rule     // Anything in parenthesis -- if, let, funcion call, etc
	| sequence_expr
	{

	}
		#me_list_create_rule    // creates a list [x]
	| TOK_NEG s = symbol
	{
		System.out.println("Token Negacion\t=====>\t#me_boolneg_rule");
    	if( $s.s.equals(typ.TypeString()))
    	{
    		$me = typ.TypeString();
    	}
    	else
    	{
    		$me = typ.TypeInteger();
    	}
	}
		#me_boolneg_rule        // Negate a variable
	| TOK_NEG '(' funcbody ')'{
			System.out.println("Negacion ( )\t=====>\t#me_boolnegparens_rule");
		}
    	#me_boolnegparens_rule  //        or anything in between ( )
	| d=metaexpr TOK_POWER e=metaexpr
	{
    	System.out.println("Exponenciacion\t=====>\t#me_exprpower_rule");
        if( $d.me.equals(typ.TypeString()) || $e.me.equals(typ.TypeString()))
        {
        	System.out.println("ERRO");
        }
        else if($d.me.equals(typ.TypeFloat()) || $d.me.equals(typ.TypeFloat()))
        {
            $me = typ.TypeFloat();
        }
        else
        {
            $me = typ.TypeInteger();
        }
	}
		#me_exprpower_rule      // Exponentiation
	| e=metaexpr TOK_CONCAT d=metaexpr
	{
		System.out.println("Concatencacion\t=====>\t#me_listconcat_rule");
        if($e.me.equals(typ.TypeString()) || $d.me.equals(typ.TypeString()))
        {
            $me = typ.TypeString();
        }
        else
        {
            System.out.println("ERRO");
		}
	}
		#me_listconcat_rule     // Sequence concatenation
	| e=metaexpr TOK_DIV_OR_MUL d=metaexpr
	{
			System.out.println("Mul Div\t=====>\t#me_exprmuldiv_rule");
            if($d.me.equals(typ.TypeString()) || $e.me.equals(typ.TypeString()))
            {
            	$e.me = null;
                System.out.println("ERRO");
            }
            else if($d.me.equals(typ.TypeFloat()) || $d.me.equals(typ.TypeFloat()))
            {
                $me = typ.TypeFloat();
            }
            else
            {
                $me = typ.TypeInteger();
            }
	}
		#me_exprmuldiv_rule     // Div and Mult are equal
	| e=metaexpr TOK_PLUS_OR_MINUS d=metaexpr
	{
			System.out.println("Mas Menos\t=====>\t#me_exprplusminus_rule");
			if($d.me.equals(typ.TypeFloat()) || $d.me.equals(typ.TypeFloat()))
            {
                $me = typ.TypeFloat();
            }
			else if($d.me.equals(typ.TypeInteger()) && $d.me.equals(typ.TypeInteger()))
            {
            	$me = typ.TypeInteger();
            }

            else
            {
            	$e.me = null;
                System.out.println("ERRO");
            }
	}
		#me_exprplusminus_rule  // Sum and Sub are equal
	| e=metaexpr TOK_CMP_GT_LT d=metaexpr {
		System.out.println("Boolean grand\t=====>\t#me_boolgtlt_rule");
        if(($e.me != $d.me) || $d.me.equals(typ.TypeString()) || $e.me.equals(typ.TypeString()))
        {
        	$e.me = null;
    		System.out.println("ERRO");
        }
        else{
        	$me = typ.TypeBoolean();
        }
	}
		#me_boolgtlt_rule       // < <= >= > are equal
	| e=metaexpr TOK_CMP_EQ_DIFF d=metaexpr
    {
		System.out.println("Boolean equals Dif\t=====>\t#me_booleqdiff_rule");
        if(($e.me != $d.me) || $d.me.equals(typ.TypeString()) || $e.me.equals(typ.TypeString()))
        {
    		System.out.println("ERRO");
        }
        else{
        	$me = typ.TypeBoolean();
        }
    }
    	#me_booleqdiff_rule     // == and != are egual
	| e=metaexpr TOK_BOOL_AND_OR d=metaexpr
	{
    	System.out.println("Boolean\t=====>\t#me_boolandor_rule ");
    	if(($e.me != $d.me) && ($d.me.equals(typ.TypeString()) || $e.me.equals(typ.TypeString())))
        {
    		$e.me = null;
    		System.out.println("ERRO");
        }
        else{
        	$me = typ.TypeBoolean();
        }
	}
		#me_boolandor_rule      // &&   and  ||  are equal
	| s = symbol
	{
		System.out.println("Symbol\t=====>\t#me_exprsymbol_rule ");
		$me = $s.s;
	}                                       #me_exprsymbol_rule     // a single symbol
	| l = literal
	{
		System.out.println("Literal\t=====>\t#me_exprliteral_rule");
		$me = $l.l;
	}                                         #me_exprliteral_rule    // literal value
	| f =funcall
	{
		System.out.println("Funcall\t=====>\t#me_exprfuncall_rule");
	}                                        #me_exprfuncall_rule    // a funcion call
	| c = cast
	{
		System.out.println("Cast\t=====>\t#me_exprcast_rule ");
		$me = $c.c;
	}
        #me_exprcast_rule       // cast a type to other
	;

sequence_expr
	: '[' funcbody ']'                               #se_create_seq ;

funcall
	: symbol funcall_params                       #funcall_rule
        /*{
            System.Console.WriteLine("Uma chamada de funcao! {0}", $symbol.text);
        }*/ ;

cast
	returns [String c]
	: t=type funcbody
	{
		$c = $t.text;
	}
    	#cast_rule ;

funcall_params
	: metaexpr funcall_params_cont                    #funcallparams_rule
	| '_'                                             #funcallnoparam_rule ;

funcall_params_cont
	: metaexpr funcall_params_cont                      #funcall_params_cont_rule
	| #funcall_params_end_rule ;

literal
	returns [String l]
	: 'nil'
	{
		System.out.println("Null\t=====>\t#literalnil_rule");
	}
		#literalnil_rule
	| 'true'
	{
		System.out.println("True\t=====>\t#literaltrue_rule");
		$l = typ.TypeBoolean();
	}
		#literaltrue_rule
	| n = number
	{
		System.out.println("Number\t=====>\t#literalnumber_rule");
		$l = $n.n;
	}
		#literalnumber_rule
	| strlit
	{
		System.out.println("String\t=====>\t#literalstring_rule");
    	$l = typ.TypeString();
	}
		#literalstring_rule
	| charlit
	{
		System.out.println("Char\t=====>\t#literal_char_rule");
    	$l = typ.TypeChar();
	}
		#literal_char_rule
	;

strlit
	returns [String sl]
	: TOK_STR_LIT
	{
		$sl = typ.TypeString();
	}
	;

charlit
	returns [String cl]
	: TOK_CHAR_LIT
	{
		$cl = typ.TypeChar();
	}
	;

number
	returns [String n]
	: FLOAT {
        	$n = typ.TypeFloat();
	}
		#numberfloat_rule
	| DECIMAL {
	    	$n = typ.TypeInteger();
	}
		#numberdecimal_rule
	| HEXADECIMAL {
    		$n = typ.TypeFloat();
	}
		#numberhexadecimal_rule
	| BINARY {
	    	$n = typ.TypeInteger();
	}
		#numberbinary_rule ;

symbol
	returns [String s]
	: TOK_ID
	{
		$s = typ.TypeString();
	}
	    #symbol_rule ;

// id: begins with a letter, follows letters, numbers or underscore
TOK_ID
	: [a-zA-Z]([a-zA-Z0-9_]*) ;

TOK_CONCAT
	: '::' ;

TOK_NEG
	: '!' ;

TOK_POWER
	: '^' ;

TOK_DIV_OR_MUL
	: ('/'|'*') ;

TOK_PLUS_OR_MINUS
	: ('+'|'-') ;

TOK_CMP_GT_LT
	: ('<='|'>='|'<'|'>') ;

TOK_CMP_EQ_DIFF
	: ('=='|'!=') ;

TOK_BOOL_AND_OR
	: ('&&'|'||') ;

TOK_REL_OP
	: ('>'|'<'|'=='|'>='|'<=') ;

TOK_STR_LIT
	: '"' (~[\"\\\r\n] | '\\' (. | EOF))* '"' ;

TOK_CHAR_LIT
	: '\'' (~[\'\n\r\\] | '\\' (. | EOF)) '\'' ;

FLOAT
	: '-'? DEC_DIGIT+ '.' DEC_DIGIT+([eE][\+-]? DEC_DIGIT+)? ;

DECIMAL
	: '-'? DEC_DIGIT+ ;

HEXADECIMAL
	: '0' 'x' HEX_DIGIT+ ;

BINARY
	: BIN_DIGIT+ 'b' ; // Sequencia de digitos seguida de b  10100b

fragment BIN_DIGIT
	: [01] ;

fragment HEX_DIGIT
	: [0-9A-Fa-f] ;

fragment DEC_DIGIT
	: [0-9] ;
