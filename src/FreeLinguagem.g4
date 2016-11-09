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
	returns [String t]
	: bt = basic_type
	{
		//System.out.println("Basic Type");
		$t = $bt.bt;
	}
		#basictype_rule
	| sequence_type {
          //  System.out.println("Variavel do tipo " + $sequence_type.base + " dimensao "+ $sequence_type.dimension);

	}
	#sequencetype_rule ;

basic_type
    returns [String bt]
	: 'int'
	{
    //	System.out.println("INTEGER");
        $bt = typ.TypeInteger();
	}
	| 'boolean'
	{
	//	System.out.println("Boolean");
        $bt = typ.TypeBoolean();
	}
	| 'str'
	{
	//	System.out.println("STRING");
        $bt = typ.TypeString();
	}
	| 'float'
	{
	//	System.out.println("FLOAT");
        $bt = typ.TypeFloat();
	}
	| 'char'
	{
	//	System.out.println("CHAR");
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
    returns[String obj]
    @after
    {
        if( $obj == "int")
        {
            System.out.println("==============>\tExpressao inteira\t<================");
        }
        if( $obj == "float")
        {
            System.out.println("==============>\tExpressao float\t\t<================");
        }
        if( $obj == "string")
        {
            System.out.println("==============>\tExpressao string\t<================");
        }
        if( $obj == "boolean")
        {
            System.out.println("==============>\tExpressao booleana\t<=============");
        }
	}
	: ifexpr                                       #fbody_if_rule
	| letexpr                                      #fbody_let_rule
	|
	{
    //	System.out.println("Em funcbody -> metaexpr");
	}
	m = metaexpr
	{
		if($m.me != null){
			$obj = $m.me;
		}
		else
		{
			System.out.println("ERRO DE TIPO. NAO CONTEMPLADO");
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
	:'(' f=funcbody ')'
		{
    		$me = $f.obj;
		//	System.out.println("Funcbody () ====> #me_exprparens_rule ");
		}
		#me_exprparens_rule     // Anything in parenthesis -- if, let, funcion call, etc
	| sequence_expr
		{
		//	System.out.println("#me_list_create_rule ");
		}
		#me_list_create_rule    // creates a list [x]
	|
	TOK_NEG s = symbol
	{
	//	System.out.println("Token Negacion\t=====>\t#me_boolneg_rule");
    	if( $s.s == typ.TypeString())
    	{
    		$me = typ.TypeString();
    	}
    	else
    	{
    		$me = typ.TypeInteger();
    	}
	}
		#me_boolneg_rule        // Negate a variable
	|
	TOK_NEG '(' funcbody ')'
	{
	//		System.out.println("Negacion ( )\t=====>\t#me_boolnegparens_rule");
	}
    	#me_boolnegparens_rule  //        or anything in between ( )
	|
	d=metaexpr TOK_POWER e=metaexpr
	{
    //	System.out.println("Exponenciacion\t=====>\t#me_exprpower_rule");
        if( $d.me == typ.TypeString() || $e.me == typ.TypeString())
        {
        	$me = null;
        	System.out.println("ERRO");
        }
        else
        {
            $me = typ.TypeFloat();
        }
	}
		#me_exprpower_rule      // Exponentiation
	|
	e=metaexpr TOK_CONCAT d=metaexpr
	{
	//	System.out.println("Concatencacion\t=====>\t#me_listconcat_rule");
        if($e.me == typ.TypeString() || $d.me == typ.TypeString())
        {
            $me = typ.TypeString();
        }
        else
        {
            System.out.println("ERRO");
		}
	}
		#me_listconcat_rule     // Sequence concatenation
	|
	e=metaexpr TOK_DIV_OR_MUL d=metaexpr
	{
	//	System.out.println("Mul Div\t=====>\t#me_exprmuldiv_rule");
        if($e.me == typ.TypeString() || $d.me == typ.TypeString())
        {
           	$me = null;
            System.out.println("ERRO");
        }
        else if($e.me == typ.TypeFloat() || $d.me == typ.TypeFloat())
        {
            $me = typ.TypeFloat();
        }
        else
        {
            $me = typ.TypeInteger();
        }
	}
		#me_exprmuldiv_rule     // Div and Mult are equal
	|
	e=metaexpr TOK_PLUS_OR_MINUS d=metaexpr
	{
	//	System.out.println("Mas Menos\t=====>\t#me_exprplusminus_rule");
        if($e.me == typ.TypeString() || $d.me == typ.TypeString())
        {
           	$me = null;
            System.out.println("ERRO");
        }
        else if($e.me == typ.TypeFloat() || $d.me == typ.TypeFloat())
        {
            $me = typ.TypeFloat();
        }
        else
        {
            $me = typ.TypeInteger();
        }
	}
		#me_exprplusminus_rule  // Sum and Sub are equal
	|
	e=metaexpr TOK_CMP_GT_LT d=metaexpr
	{
	//	System.out.println("Boolean grand\t=====>\t#me_boolgtlt_rule");
        if($d.me == typ.TypeString() || $e.me == typ.TypeString())
        {
        	$me = null;
    		System.out.println("ERRO");
        }
        else{
        	$me = typ.TypeBoolean();
        }
	}
		#me_boolgtlt_rule       // < <= >= > are equal
	|
	e=metaexpr TOK_CMP_EQ_DIFF d=metaexpr
    {
	//	System.out.println("Boolean equals Dif\t=====>\t#me_booleqdiff_rule");
	//	try{
	    	if($e.me == typ.TypeString() || $d.me == typ.TypeString())
	        {
	    		$me = null;
	    		System.out.println("ERRO");
	        }
	        else{
	        	$me = typ.TypeBoolean();
	        }
	//    }
	//	catch(Exception e){
	//		e.printStackTrace();
	//	}
	//	finally{
	//		System.out.println($me );
	//	}
    }
    	#me_booleqdiff_rule     // == and != are egual
	|
	e=metaexpr TOK_BOOL_AND_OR d=metaexpr
	{
    //    System.out.println("Boolean\t=====>\t#me_boolandor_rule ");
    	if($e.me == typ.TypeString() || $d.me == typ.TypeString())
        {
    		$me = null;
    		System.out.println("ERRO");
        }
        else{
        	$me = typ.TypeBoolean();
        }
	}
		#me_boolandor_rule      // &&   and  ||  are equal
	|
	{
	//	System.out.println("Symbol\t=====>\t#me_exprsymbol_rule ");
	}
	s = symbol
	{
		$me = $s.s;
	}                                       #me_exprsymbol_rule     // a single symbol
	|
	{
	//	System.out.println("Literal\t=====>\t#me_exprliteral_rule");
	}
	l = literal
	{
		$me = $l.l;
	}                                         #me_exprliteral_rule    // literal value
	|
	f = funcall
	{
	//	System.out.println("Funcall\t=====>\t#me_exprfuncall_rule");
	}
		#me_exprfuncall_rule    // a funcion call
	|
	{
	//	System.out.println("Cast\t=====>\t#me_exprcast_rule");
	}
	c = cast
	{
		$me = $c.c;
	}
        #me_exprcast_rule       // cast a type to other
	;

sequence_expr
	: '[' funcbody ']'                               #se_create_seq ;

funcall
	: symbol funcall_params                       #funcall_rule
	| symbol metaexpr #funcall_rule2
        /*{
            System.Console.WriteLine("Uma chamada de funcao! {0}", $symbol.text);
        }*/ ;

cast
	returns [String c]
	:
	{
	//	System.out.println("CAST =====> #cast_rule");
	}
	t=type f=funcbody
	{
		$c = $t.t;
		/*
		if($t.t == typ.TypeString() || $f.obj == typ.TypeString())
		{
			$c = null;
		}
		else if($t.t == typ.TypeFloat() || $f.obj == typ.TypeFloat())
		{
			$c = typ.TypeFloat();
		}
		else
		{
			System.out.println($t.t + "_____" + $f.obj);
			$c = typ.TypeInteger();
		}*/

	}
    	#cast_rule ;

funcall_params
	: metaexpr funcall_params_cont                    #funcallparams_rule
	| '_'                                             #funcallnoparam_rule ;

funcall_params_cont
	: metaexpr funcall_params_cont
		#funcall_params_cont_rule
	|
		#funcall_params_end_rule ;

literal
	returns [String l]
	:
	{
	//	System.out.println("Null\t=====>\t#literalnil_rule");
	}
	'nil'
		#literalnil_rule
	|
	{
	//	System.out.println("True\t=====>\t#literaltrue_rule");
	}
	'true'
	{
		$l = typ.TypeBoolean();
	}
		#literaltrue_rule
	|
	{
	//	System.out.println("Number\t=====>\t#literalnumber_rule");
	}
	n = number
	{
		$l = $n.n;
	}
		#literalnumber_rule
	|
	{
	//	System.out.println("String\t=====>\t#literalstring_rule");
	}
	strlit
	{
    	$l = typ.TypeString();
	}
		#literalstring_rule
	|
	{
	//	System.out.println("Char\t=====>\t#literal_char_rule");
	}
	charlit
	{
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
	:
	{
	//	System.out.println("NUMBER\t=====>\t#numberfloat_rule");
	}
	FLOAT
	{
        $n = typ.TypeFloat();
	}
		#numberfloat_rule
	|
	{
	//	System.out.println("DECIMAL\t=====>\t#numberdecimal_rule");
	}
	DECIMAL {
	    $n = typ.TypeInteger();
	}
		#numberdecimal_rule
	|
	{
	//	System.out.println("HEXADECIMAL\t=====>\t#numberdecimal_rule");
	}
	HEXADECIMAL
	{
    	$n = typ.TypeInteger();;
	}
		#numberhexadecimal_rule
	|
	{
	//	System.out.println("BINARY\t=====>\t#numberbinary_rule");
	}
	BINARY
	{
	    $n = typ.TypeInteger();
	}
		#numberbinary_rule ;

symbol
	returns [String s]
	: tk=TOK_ID
	{
	//	System.out.println("Symbols===#symbol_rule" + "____" + $tk.text);
		if($tk.text.equals("i"))
			$s = typ.TypeInteger();
		else if($tk.text.equals("s"))
			$s = typ.TypeString();
		else if($tk.text.equals("b"))
			$s = typ.TypeBoolean();
		else if($tk.text.equals("f"))
			$s = typ.TypeFloat();
		else
			$s = null;
	//	System.out.println($s);
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
