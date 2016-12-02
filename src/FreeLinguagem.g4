grammar FreeLinguagem ;

@header
	{
		import java.util.*;
		import types.*;
	}

@members
	{
		NestedSymbolTable<String> nstMainVariaveis = new NestedSymbolTable<String>();
		NestedSymbolTable<Object> nstMainValues = new NestedSymbolTable<Object>();
		Stack<Object> pilha = new Stack<Object>();
		Type typ = new Type();
		private void printPilha(){
			if(pilha.size() > 0)
				System.out.println("====================================================================");
					System.out.println(pilha.pop());
				System.out.println("====================================================================");
		}
		private void printValuesAndVariaveis(){
			if(nstMainVariaveis.getCount() > 0){
				for (SymbolEntry<String> entry : nstMainVariaveis.getEntries()){
					System.out.println("Variaveis =====> " + entry);
				}
				System.out.println("====================================================================");
			}
			if(nstMainValues.getCount() > 0){
				for (SymbolEntry<Object> entry : nstMainValues.getEntries()){
					System.out.println("Values =====> " + entry);
				}
				System.out.println("====================================================================");
			}
		}
	}

WS
	:
	[ \r\t\u000C\n]+ -> channel(HIDDEN)
	;

COMMENT
	:
	'//' ~('\n'|'\r')* '\r'? '\n' -> channel(HIDDEN)
	;

program
	:
	fdecls maindecl
	{
		System.out.println("Parseou um programa!");
	}
	;

fdecls
	:
	fdecl fdecls
		#fdecls_one_decl_rule
	|
		#fdecls_end_rule
	;

maindecl
	:
	'def' 'main' '=' funcbody
		#programmain_rule ;

fdecl
	:
	'def' functionname fdeclparams '=' funcbody
	{
		//System.Console.WriteLine("Achou declaração: {0} com {1}", $functionname.text, $fdeclparams.plist.ToString());
	}
		#funcdef_rule
    ;

fdeclparams
returns [List<String> plist]
@ init
	{
		$plist = new ArrayList<String>();
	}
@ after
	{
    	for (String s : $plist) {
        	System.out.println("Parametro: " + s);
    	}
	}
	:
	fdeclparam
	{
		$plist.add($fdeclparam.pname);
	}
	fdeclparams_cont[$plist]
		#fdeclparams_one_param_rule
	|
		#fdeclparams_no_params
	;

fdeclparams_cont [List<String> plist]
	:
	',' fdeclparam
	{
		$plist.add($fdeclparam.pname);
	}
	fdeclparams_cont[$plist]
		#fdeclparams_cont_rule
	|
		#fdeclparams_end_rule
	;

fdeclparam
    returns [String pname, String ptype]
	:
	symbol ':' type
	{
		$pname = $symbol.text;
		$ptype = $type.text;
	}
		#fdecl_param_rule
	;

functionname
	:
	TOK_I
		#fdecl_funcname_rule
	;

type
	returns [String t]
	:
	bt = basic_type
	{
		$t = $bt.bt;
	}
		#basictype_rule
	|
	sequence_type
	{
		//  System.out.println("Variavel do tipo " + $sequence_type.base + " dimensao "+ $sequence_type.dimension);
	}
		#sequencetype_rule
	;

basic_type
    returns [String bt]
	:
	'int'
	{
    	// System.out.println("INTEGER");
        $bt = typ.TypeInteger();
	}
	|
	'boolean'
	{
		//	System.out.println("Boolean");
        $bt = typ.TypeBoolean();
	}
	|
	'str'
	{
		//	System.out.println("STRING");
		$bt = typ.TypeString();
	}
	|
	'float'
	{
		//	System.out.println("FLOAT");
		$bt = typ.TypeFloat();
	}
	|
	'char'
	{
		//	System.out.println("CHAR");
		$bt = typ.TypeChar();
	}
	;

sequence_type
returns [int dimension=0, String base]
	: basic_type '[]'
	{
		$dimension = 1;
		$base = $basic_type.text;
	}
		#sequencetype_basetype_rule
	|
	s=sequence_type '[]'
	{
		$dimension = $s.dimension + 1;
		$base = $s.base;
	}
		#sequencetype_sequence_rule
	;


interpreter
@after{
	printPilha();
}
	:
		funcbody
	;

funcbody
    returns[String f, String value]
@after{
	//printPilha();
}
	:
	ifexpr
		#fbody_if_rule
	|
	{
    	//	System.out.println("Em funcbody -> letexpr");
	}
	lex = letexpr
	{
		$f = $lex.lex;
		$value = $lex.value;
	}
		#fbody_let_rule
	|
	{
		// System.out.println("Em funcbody -> metaexpr");
	}
	m = metaexpr
	{
		$f = $m.me;
		$value = $m.value;
	}
		#fbody_expr_rule ;

ifexpr
	:
	'if' funcbody 'then' funcbody 'else' funcbody
	{
	}
		#ifexpression_rule ;

letexpr
returns[String lex, String value]
	:
	{
	}
	'let' l = letlist 'in'
	{
		nstMainVariaveis = $l.nstLocal;
		nstMainValues = $l.nstLocalValues;
	}
	f = funcbody
	{
		nstMainVariaveis = nstMainVariaveis.getParent();
		nstMainValues = nstMainValues.getParent();
		$lex = $f.f;
		$value = $f.value;
		//System.out.println($lex + " ==__== " + $value);
	}
		#letexpression_rule
	;

letlist
returns [NestedSymbolTable<String> nstLocal, NestedSymbolTable<Object> nstLocalValues]
@init{
		$nstLocal = new NestedSymbolTable<String>(nstMainVariaveis);
		$nstLocalValues = new NestedSymbolTable<Object>(nstMainValues);
		nstMainVariaveis = $nstLocal;
		nstMainValues = $nstLocalValues;
	}
	:
	lve = letvarexpr
	{
		$nstLocal.store($lve.lve1, $lve.lve2);
		$nstLocalValues.store($lve.lve1,$lve.value);
	}
	llc = letlist_cont[$nstLocal, $nstLocalValues]
	{
	}
		#letlist_rule
	;

letlist_cont[NestedSymbolTable<String> nstLocal, NestedSymbolTable<Object> nstLocalValues]
	:
	',' lve = letvarexpr
	{
		$nstLocal.store($lve.lve1, $lve.lve2);
		$nstLocalValues.store($lve.lve1,$lve.value);
	}
	letlist_cont[$nstLocal, $nstLocalValues]
	{

	}
		#letlist_cont_rule
	|
		#letlist_cont_end
	;

letvarexpr
	returns [String lve1, String lve2, String value]
	:
	{
		//	System.out.println("LET VAR RES IGNORE\t======>\t#letvarresult_ignore_rule");
	}
	s = symbol
	{
		$lve1 = $s.text;
	}
	'=' f = funcbody
	{
		$lve2 = $f.f;
		$value = $f.value;
	}
		#letvarattr_rule
	|
	'_'   '=' f = funcbody
	{
		$lve1 = "_";
		$lve2 = $f.f;
		$value = $f.value;
	}
		#letvarresult_ignore_rule
	|
	se = symbol '::' sd = symbol
	{
		$lve1 = $se.text + $sd.text;
		$value = $se.text + $sd.text;
	}
	'=' f = funcbody
	{
		$lve2 = $f.f;
		$value = $f.value;
	}
		#letunpack_rule
	;

metaexpr
    returns [String me, String value]
	:
	'(' f=funcbody ')'
	{
    	$me = $f.f;
    	$value = $f.value;
    	// System.out.println($f.f + " / " + $f.value);
		//	System.out.println("Funcbody () ====> #me_exprparens_rule ");
	}
		#me_exprparens_rule     // Anything in parenthesis -- if, let, funcion call, etc
	|
	sequence_expr
	{
		//System.out.println("#me_list_create_rule ");
	}
		#me_list_create_rule    // creates a list [x]
	|
	TOK_NEG s = symbol
	{
		//	System.out.println("Token Negacion\t=====>\t#me_boolneg_rule");
    	if( $s.s == typ.TypeString()){
    		$me = typ.TypeString();
    	}
    	else{
    		$me = typ.TypeInteger();
    	}
	}
		#me_boolneg_rule        // Negate a variable
	|
	TOK_NEG '(' funcbody ')'
	{
		//	System.out.println("Negacion ( )\t=====>\t#me_boolnegparens_rule");

	}
		#me_boolnegparens_rule  //  or anything in between ( )
	|
	d=metaexpr TOK_POWER e=metaexpr
	{
    	//	System.out.println("Exponenciacion\t=====>\t#me_exprpower_rule");
        if( $d.me == typ.TypeString() || $e.me == typ.TypeString()){
        	$me = null;
        	System.out.println("ERRO");
        }
        else{
            $me = typ.TypeFloat();
        }
	}
		#me_exprpower_rule      // Exponentiation
	|
	e=metaexpr TOK_CONCAT d=metaexpr
	{
		if($d.me == typ.TypeString() || $e.me == typ.TypeString()){
			$me = typ.TypeString();
			String v1 = $e.value.toString();
			String v2 = $d.value.toString();
	        $value = v1.replace("\"","") + v2.replace("\"","");
        	// System.out.println("CONCATENANDO " + pilha.size());
			v2 = (String)pilha.pop();
        	v1 = (String)pilha.pop();
        	String v3 = v1 + v2;
        	// System.out.println(v1+" - "+ v2 +" - "+ v3 );
        	pilha.push( $value );
	    }
	}
		#me_listconcat_rule     // Sequence concatenation
	|
	e=metaexpr tk = TOK_DIV_OR_MUL d=metaexpr
	{
			// System.out.println("MULTIPLICANDO "+ pilha.size());
			Integer v1 = Integer.parseInt($e.value.toString());
        	Integer v2 = Integer.parseInt($d.value.toString());
        	// System.out.println("MULTIPLICANDO "+ pilha.size() + "-" + v1 + "-" + v2);
        	if(pilha.size() <  2){
            	pilha.pop();
        	}
        	else{
            	pilha.pop();
            	pilha.pop();
        	}
			//>
        	if($tk.text.equals("*")){
        		$value = String.valueOf(new Integer(v1 * v2));
        		pilha.push($value);
        	}
        	if($tk.text.equals("/")){
        		$value = String.valueOf(new Integer(v1 / v2));
        		pilha.push($value);
        	}
            $me = typ.TypeInteger();
	}
		#me_exprmuldiv_rule     // Div and Mult are equal
	|
	e=metaexpr tk = TOK_PLUS_OR_MINUS d=metaexpr
	{
			// System.out.println("SOMANDO"+ pilha.size());
			Integer v1 = Integer.parseInt($e.value.toString());
        	Integer v2 = Integer.parseInt($d.value.toString());
        	// System.out.println("SOMANDO"+ pilha.size() + "-" + v1 + "-" + v2);
        	if(pilha.size() <  2){
            	pilha.pop();
        	}
        	else{
            	pilha.pop();
            	pilha.pop();
        	}
        	if($tk.text.equals("+")){
        		$value = String.valueOf(new Integer(v1 + v2));
        		pilha.push($value);
        	}
        	if($tk.text.equals("-")){
        		$value = String.valueOf(new Integer(v1 - v2));
        		pilha.push($value);
        	}
            $me = typ.TypeInteger();
	}
		#me_exprplusminus_rule  // Sum and Sub are equal
	|
	e=metaexpr TOK_CMP_GT_LT d=metaexpr
	{
		//	System.out.println("Boolean grand\t=====>\t#me_boolgtlt_rule");
        if($d.me == typ.TypeString() || $e.me == typ.TypeString()){
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
	    if($e.me == typ.TypeString() || $d.me == typ.TypeString()){
	    	$me = null;
	    	System.out.println("ERRO");
	    }
	    else{
	        $me = typ.TypeBoolean();
	    }
	}
	    #me_booleqdiff_rule     // == and != are egual
	|
	e=metaexpr TOK_BOOL_AND_OR d=metaexpr
	{
        	$me = typ.TypeBoolean();
	}
		#me_boolandor_rule      // &&   and  ||  are equal
	|
	s = symbol
	{
		// System.out.println($s.text + "*********************");
		if(nstMainVariaveis.lookup($s.text) != null){
			String value = nstMainVariaveis.lookup($s.text).symbol.toString();
			$me = value;

		}
		if(nstMainValues.lookup($s.text) != null){
			String valuePilha = nstMainValues.lookup($s.text).symbol.toString();
			$value = valuePilha;
			valuePilha = valuePilha.replace("\"","");
			//System.out.println("Pushando symbol " + valuePilha +"*****************" );
			pilha.push(valuePilha);
		}
	}
		#me_exprsymbol_rule     // a single symbol
	|
	{
		// System.out.println("Literal\t=====>\t#me_exprliteral_rule");
	}
	l = literal
	{
		$me = $l.l;
		$value = $l.value;
		//System.out.println($me + "//" + $value);
		//System.out.println("Expressao literal\t======>\t#me_exprliteral_rule ");
		/*if(nstMainValues.lookup($l.text) != null){
			System.out.println("PUSHANDO_ "+nstMainValues.lookup($l.text).symbol);
			pilha.push(nstMainValues.lookup($l.text).symbol);
			$me = nstMainVariaveis.lookup($l.text).symbol;
		}
		else{
			$me = typ.TypeString();
		}*/
	}
		#me_exprliteral_rule    // literal value
	|
	f = funcall
	{
		//	System.out.println("Funcall\t=====>\t#me_exprfuncall_rule");
	}
		#me_exprfuncall_rule    // a funcion call
	|
	{
		//System.out.println("Cast\t=====>\t#me_exprcast_rule");
	}
	c = cast
	{
		$me = $c.c;
		$value = $c.value;
		pilha.push($value.replace("\"",""));
	}
		#me_exprcast_rule       // cast a type to other
	;

sequence_expr
	:
	'[' funcbody ']'
		#se_create_seq
	;

funcall
	:
	symbol funcall_params
		#funcall_rule
	|
	symbol metaexpr
    {
      //	System.Console.WriteLine("Uma chamada de funcao! {0}", $symbol.text);
    }
    	#funcall_rule2
    ;

cast
	returns [String c, String value]
	:
	{
		//	System.out.println("CAST =====> #cast_rule");
	}
	t=type f=funcbody
	{
		$c = $t.t;
		$value = $f.value;
	}
	    #cast_rule
	;

funcall_params
	:
	metaexpr funcall_params_cont
		#funcallparams_rule
	|
	'_'
		#funcallnoparam_rule
	;

funcall_params_cont
	:
	metaexpr funcall_params_cont
		#funcall_params_cont_rule
	|
		#funcall_params_end_rule
	;

literal
	returns [String l, String value]
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
		$value = "true";
	}
		#literaltrue_rule
	|
	{
		//	System.out.println("Number\t=====>\t#literalnumber_rule");
	}
	n = number
	{
		$l = $n.n;
		$value = $n.value;
	}
		#literalnumber_rule
	|
	{
		//	System.out.println("String\t=====>\t#literalstring_rule");
	}
	str = strlit
	{
		$l = $str.str;
		$value = $str.value;
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
	returns [String str, String value]
	:
	tk = TOK_STR_LIT
	{
		$str = typ.TypeString();
		$value = $tk.text;
	}
	;

charlit
	returns [String cl]
	:
	TOK_CHAR_LIT
	{
		$cl = typ.TypeChar();
	}
	;

number
	returns [String n, String value]
	:
	tk = FLOAT
	{
		$value = $tk.text;
		$n = typ.TypeFloat();
	}
		#numberfloat_rule
	|
	tk = DECIMAL
	{
		$value = $tk.text;
		$n = typ.TypeInteger();
	}
		#numberdecimal_rule
	|
	tk = HEXADECIMAL
	{
		$value = $tk.text;
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
		#numberbinary_rule
	;

symbol
	returns [String s]
	:
	tk=TOK_ID
	{
		/*if(pilha.size() > 0)
			$s = pilha.pop();
		else*/
		//$s = $tk.text;
		//$s = (String) pilha.pop();
	}
		#symbol_rule
	;

// id: begins with a letter, follows letters, numbers or underscore
TOK_ID
	:
	[a-zA-Z]([a-zA-Z0-9_]*)
	;

TOK_CONCAT
	:
	'::'
	;

TOK_NEG
	:
	'!'
	;

TOK_POWER
	:
	'^'
	;

TOK_DIV_OR_MUL
	:
	('/'|'*')
	;

TOK_PLUS_OR_MINUS
	:
	('+'|'-')
	;

TOK_CMP_GT_LT
	:
	('<='|'>='|'<'|'>')
	;

TOK_CMP_EQ_DIFF
	:
	('=='|'!=')
	;

TOK_BOOL_AND_OR
	:
	('&&'|'||')
	;

TOK_REL_OP
	:
	('>'|'<'|'=='|'>='|'<=')
	;

TOK_STR_LIT
	:
	'"' (~[\"\\\r\n] | '\\' (. | EOF))* '"'
	;

TOK_CHAR_LIT
	:
	'\'' (~[\'\n\r\\] | '\\' (. | EOF)) '\''
	;

FLOAT
	:
	'-'? DEC_DIGIT+ '.' DEC_DIGIT+([eE][\+-]? DEC_DIGIT+)?
	;

DECIMAL
	:
	'-'? DEC_DIGIT+
	;

HEXADECIMAL
	:
	'0' 'x' HEX_DIGIT+
	;

BINARY
	:
	BIN_DIGIT+ 'b'
	; // Sequencia de digitos seguida de b  10100b

fragment BIN_DIGIT
	:
	[01]
	;

fragment HEX_DIGIT
	:
	[0-9A-Fa-f]
	;

fragment DEC_DIGIT
	:
	[0-9]
	;
