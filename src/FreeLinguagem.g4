grammar FreeLinguagem;


@header {
import java.util.*;
}


@members {
	List<String> symbolTable = new ArrayList<String>();
}

WS : [ \r\t\u000C\n]+ -> channel(HIDDEN)
    ;

COMMENT : '//' ~('\n'|'\r')* '\r'? '\n' -> channel(HIDDEN);

program
    : fdecls maindecl
	    {
	    	System.out.println("Parseou um programa!");
	    }
    ;

fdecls
    : fdecl fdecls                                   #fdecls_one_decl_rule
    |                                                #fdecls_end_rule
    ;

maindecl: 'def' 'main' '=' funcbody                  #programmain_rule
    ;

fdecl: 'def' functionname fdeclparams '=' funcbody   #funcdef_rule
        /*{
            System.Console.WriteLine("Achou declaração: {0} com {1}", $functionname.text, $fdeclparams.plist.ToString());
        }*/
    ;

fdeclparams
returns [List<String> plist]
@init {
    $plist = new ArrayList<String>();
}
@after {
    for (String s : $plist) {
        System.out.println("Parametro: " + s);
    }
}
    :   fdeclparam
        {
            $plist.add($fdeclparam.pname);
        }
        fdeclparams_cont[$plist]

                                                     #fdeclparams_one_param_rule
    |                                                #fdeclparams_no_params
    ;

fdeclparams_cont[List<String> plist]
    : ',' fdeclparam
        {
            $plist.add($fdeclparam.pname);
        }
        fdeclparams_cont[$plist]
                                                     #fdeclparams_cont_rule
    |                                                #fdeclparams_end_rule
    ;

fdeclparam
    returns [String pname, String ptype]
    : symbol ':' type
        {
            $pname = $symbol.text;
            $ptype = $type.text;
        }
        #fdecl_param_rule
    ;

functionname
	:
		TOK_ID                                 #fdecl_funcname_rule
    ;

type
    returns [Type t]
    :
    b = basic_type
		{
            t = b.bt;
        }
        #basictype_rule
    |   sequence_type
        {
            System.out.println("Variavel do tipo " + $sequence_type.base + " dimensao "+ $sequence_type.dimension);
        }
                                                    #sequencetype_rule
    ;

basic_type
    returns [Type bt]
    : 'i'
        {
            bt = Type.Integer;
        }
    | 'b'
        {
            bt = Type.Boolean;
        }
    | 's'
        {
            bt = Type.String;
        }
    | 'f'
        {
            bt = Type.Float;
        }
   	| 'c'
   		{
   			bt = Type.Char;
   		}
    ;

sequence_type
returns [int dimension=0, String base]
    :   basic_type '[]'
        {
            $dimension = 1;
            $base = $basic_type.text;
        }

                                                     #sequencetype_basetype_rule
    |   s=sequence_type '[]'
        {
            $dimension = $s.dimension + 1;
            $base = $s.base;
        }
                                                     #sequencetype_sequence_rule
    ;

funcbody
    returns[Object obj]
    :
        ifexpr                                       #fbody_if_rule
    |   letexpr                                      #fbody_let_rule
    ;

interprete
	:
	m = metaexpr
        {
            System.out.println("Comecando o programa");  
            symbolTable.add(obj);    
            if( m.me == Type.Integer)
            {
                System.out.println("Expressao inteira");
            } 
            if( m.me == Type.Float)
            {
                System.out.println("Expressao float");
            } 
            if( m.me == Type.String)
            {
                System.out.println("Expressao string");
            } 
            if( m.me == Type.Boolean)
            {
                System.out.println("Expressao booleana");
            }
        }
      #fbody_expr_rule
	;
ifexpr
    : 'if' funcbody 'then' funcbody 'else' funcbody  #ifexpression_rule
    ;

letexpr
    : 'let' letlist 'in' funcbody                    #letexpression_rule
    ;

letlist
    : letvarexpr  letlist_cont                       #letlist_rule
    ;

letlist_cont
    : ',' letvarexpr letlist_cont                    #letlist_cont_rule
    |                                                #letlist_cont_end
    ;

letvarexpr
    :    symbol '=' funcbody                         #letvarattr_rule
    |    '_'    '=' funcbody                         #letvarresult_ignore_rule
    |    symbol '::' symbol '=' funcbody             #letunpack_rule
    ;

metaexpr
    returns [Type me]
    : '(' funcbody ')'                               #me_exprparens_rule     // Anything in parenthesis -- if, let, funcion call, etc
    | sequence_expr                                  #me_list_create_rule    // creates a list [x]
    | TOK_NEG s = symbol
    {
    	if( s.s == Type.String )
    	{
    		me = Type.String;
    	}
    	else
    	{
    		me = Type.Integer;
    	}
    }
    	#me_boolneg_rule        // Negate a variable
    | TOK_NEG '(' funcbody ')'
    	#me_boolnegparens_rule  //        or anything in between ( )
    | d=metaexpr TOK_POWER e=metaexpr
    {
        if(d.me == Type.String || e.me == Type.String)
        {
        	System.out.println("ERRO");
        }
        else if(d.me == Type.Float || d.me == Type.Float)
        {
            me = Type.Float;
        }
        else
        {
            me = Type.Integer;
        }
    }
        #me_exprpower_rule      // Exponentiation
    | e=metaexpr TOK_CONCAT d=metaexpr
    {
        if(e.me == Type.String || d.me == Type.String)
        {
            me = Type.String;
        }
        else
        {
            System.out.println("ERRO");
		}
    }
        #me_listconcat_rule     // Sequence concatenation
    | e=metaexpr TOK_DIV_OR_MUL d=metaexpr
        {
            if(d.me == Type.String || e.me == Type.String)
            {
                System.out.println("ERRO");
            }
            else if(d.me == Type.Float || d.me == Type.Float)
            {
                me = Type.Float;
            }
            else
            {
                me = Type.Integer;
            }
        }
        #me_exprmuldiv_rule     // Div and Mult are equal
    | e=metaexpr TOK_PLUS_OR_MINUS d=metaexpr
        {
            if(d.me == Type.String || e.me == Type.String)
            {
                System.out.println("ERRO");
            }
            else if(d.me == Type.Float || d.me == Type.Float)
            {
                me = Type.Float;
            }
            else
            {
                me = Type.Integer;
            }
        }
        #me_exprplusminus_rule  // Sum and Sub are equal
    | e=metaexpr TOK_CMP_GT_LT d=metaexpr
    {
        if((e.me != d.me) || d.me == Type.String || e.me == Type.String )
        {
    		System.out.println("ERRO");
        }
        else{
        	me = Type.Boolean;
        }
    }
    	#me_boolgtlt_rule       // < <= >= > are equal
    | e=metaexpr TOK_CMP_EQ_DIFF d=metaexpr
     {
        if((e.me != d.me) || d.me == Type.String || e.me == Type.String )
        {
    		System.out.println("ERRO");
        }
        else{
        	me = Type.Boolean;
        }
    }
    	#me_booleqdiff_rule     // == and != are egual
    | metaexpr TOK_BOOL_AND_OR metaexpr
     {
        if((e.me != d.me) || d.me == Type.String || e.me == Type.String )
        {
    		System.out.println("ERRO");
        }
        else{
        	me = Type.Boolean;
        }
    }
    	#me_boolandor_rule      // &&   and  ||  are equal
    | symbol                                         #me_exprsymbol_rule     // a single symbol
    | literal                                        #me_exprliteral_rule    // literal value
    | funcall                                        #me_exprfuncall_rule    // a funcion call
    | cast
    {
    	m = c;
    }
        #me_exprcast_rule       // cast a type to other
    ;

sequence_expr
    : '[' funcbody ']'                               #se_create_seq
    ;

funcall: symbol funcall_params                       #funcall_rule
        /*{
            System.Console.WriteLine("Uma chamada de funcao! {0}", $symbol.text);
        }*/
    ;

cast
	returns [Type c]
    :
    t=type funcbody
    {
    	c = t.t; 
    }
    	#cast_rule
    ;

funcall_params
    :   metaexpr funcall_params_cont                    #funcallparams_rule
    |   '_'                                             #funcallnoparam_rule
    ;

funcall_params_cont
    : metaexpr funcall_params_cont                      #funcall_params_cont_rule
    |                                                   #funcall_params_end_rule
    ;

literal
	returns [Type l]
	:
        'nil'                                           #literalnil_rule
    |   'true'                                          #literaltrue_rule
    |   n = number
    {
		l = n.n;
    }
    	#literalnumber_rule
    |   sl = strlit
    {
    	l = sl.sl;
    }
    	#literalstring_rule
    |   cl = charlit
    {
    	l = cl.cl;
    }                                         #literal_char_rule
    ;

strlit
	returns [Type sl]
	:
		TOK_STR_LIT
    ;

charlit
	returns [Type cl]
    :
    	TOK_CHAR_LIT
    ;

number
	returns [Type n]:
        FLOAT
        {
        	n = Type.Float;
        }
        #numberfloat_rule
    |   DECIMAL
	    {
	    	n = Type.Float;
	    }                                        	    #numberdecimal_rule
    |   HEXADECIMAL
    	{
    		n = Type.Integer;
    	}                                               #numberhexadecimal_rule
    |   BINARY
	    {
	    	n = Type.Integer;
	    }                                               #numberbinary_rule
      ;

symbol
	returns [Type s]
	:
		TOK_ID                                #symbol_rule
    ;


// id: begins with a letter, follows letters, numbers or underscore
TOK_ID: [a-zA-Z]([a-zA-Z0-9_]*);

TOK_CONCAT: '::' ;
TOK_NEG: '!';
TOK_POWER: '^' ;
TOK_DIV_OR_MUL: ('/'|'*');
TOK_PLUS_OR_MINUS: ('+'|'-');
TOK_CMP_GT_LT: ('<='|'>='|'<'|'>');
TOK_CMP_EQ_DIFF: ('=='|'!=');
TOK_BOOL_AND_OR: ('&&'|'||');

TOK_REL_OP : ('>'|'<'|'=='|'>='|'<=') ;

TOK_STR_LIT
  : '"' (~[\"\\\r\n] | '\\' (. | EOF))* '"'
  ;


TOK_CHAR_LIT
    : '\'' (~[\'\n\r\\] | '\\' (. | EOF)) '\''
    ;

FLOAT : '-'? DEC_DIGIT+ '.' DEC_DIGIT+([eE][\+-]? DEC_DIGIT+)? ;

DECIMAL : '-'? DEC_DIGIT+ ;

HEXADECIMAL : '0' 'x' HEX_DIGIT+ ;

BINARY : BIN_DIGIT+ 'b' ; // Sequencia de digitos seguida de b  10100b

fragment
BIN_DIGIT : [01];

fragment
HEX_DIGIT : [0-9A-Fa-f];

fragment
DEC_DIGIT : [0-9] ;
