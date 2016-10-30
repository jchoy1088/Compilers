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
    : fdecls maindecl {System.out.println("Parseou um programa!");}
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

functionname: TOK_ID                                 #fdecl_funcname_rule
    ;

type
    returns [Type t]
    : basic_type 
        {
            t = basic_type.bt;
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
    : 'int'
        {
            bt = Type.Integer;
        }
    | 'bool'
        {
            bt = Type.Boolean;
        }
    | 'str'
        {
            bt = Type.String;
        }
    | 'float'
        {
            bt = Type.Float;
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
    |   metaexpr                                     #fbody_expr_rule
    ;


interpreter
    returns [String i]
    @after{
        for(String str : symbolTable)
            System.out.println("Value :" + str);
    }
    :
        m = metaexpr   
        {
            System.out.println("Comecando o programa");  
            symbolTable.add(obj);    
            if( i.me == Type.Integer)
                System.out.println("Expressao inteira"); 
            if( i.me == Type.Float)
                System.out.println("Expressao float"); 
            if( i.me == Type.String)
                System.out.println("Expressao string"); 
            if( i.me == Type.Boolean)
                System.out.println("Expressao booleana");
        }
        
        #fbody_vali_rule
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
    | TOK_NEG symbol                                 #me_boolneg_rule        // Negate a variable
    | TOK_NEG '(' funcbody ')'                       #me_boolnegparens_rule  //        or anything in between ( )
    | d=metaexpr TOK_POWER e=metaexpr     
        {
            if(d.me == Type.String || e.me == Type.String)
                System.out.println("ERRO");
            else if(d.me == Type.Float || d.me == Type.Float)
                me = Type.Float;
            else
                me = Type.Integer;
        }
        #me_exprpower_rule      // Exponentiation
    | e=metaexpr TOK_CONCAT d=metaexpr    
        {
            if(e.me == Type.String || d.me == Type.String)
                me = Type.String;
            else
                System.out.println("ERRO");

        }
        #me_listconcat_rule     // Sequence concatenation
    | e=metaexpr TOK_DIV_OR_MUL d=metaexpr
        {
            if(d.me == Type.String || e.me == Type.String)
                System.out.println("ERRO");
            else if(d.me == Type.Float || d.me == Type.Float)
                me = Type.Float;
            else
                me = Type.Integer;
        }
        #me_exprmuldiv_rule     // Div and Mult are equal
    | e=metaexpr TOK_PLUS_OR_MINUS d=metaexpr  
        {
            if(d.me == Type.String || e.me == Type.String)
                System.out.println("ERRO");
            else if(d.me == Type.Float || d.me == Type.Float)
                me = Type.Float;
            else
                me = Type.Integer;
        }          #me_exprplusminus_rule  // Sum and Sub are equal
    | d=metaexpr TOK_CMP_GT_LT e=metaexpr
        {
            if(d.me == Type.String || e.me == Type.String)
                System.out.println("ERRO");
            else if(d.me == Type.Float || d.me == Type.Float)
                me = Type.Float;
            else
                me = Type.Integer;
        }                #me_boolgtlt_rule       // < <= >= > are equal
    | metaexpr TOK_CMP_EQ_DIFF metaexpr              #me_booleqdiff_rule     // == and != are egual
    | metaexpr TOK_BOOL_AND_OR metaexpr              #me_boolandor_rule      // &&   and  ||  are equal
    | symbol  {
    
    		  }                                Float      #me_exprsymbol_rule     // a single symbol
    | literal                                        #me_exprliteral_rule    // literal value
    | funcall                                        #me_exprfuncall_rule    // a funcion call
    | cast                                           #me_exprcast_rule       // cast a type to other
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
    : type funcbody                                  #cast_rule
    ;

funcall_params
    :   metaexpr funcall_params_cont                    #funcallparams_rule
    |   '_'                                             #funcallnoparam_rule
    ;

funcall_params_cont
    : metaexpr funcall_params_cont                      #funcall_params_cont_rule
    |                                                   #funcall_params_end_rule
    ;

literal:
        'nil'                                           #literalnil_rule
    |   'true'                                          #literaltrue_rule
    |   number                                          #literalnumber_rule
    |   strlit                                          #literalstring_rule
    |   charlit                                         #literal_char_rule
    ;

strlit: TOK_STR_LIT
    ;

charlit
    : TOK_CHAR_LIT
    ;

number:
        FLOAT                                           #numberfloat_rule
    |   DECIMAL                                         #numberdecimal_rule
    |   HEXADECIMAL                                     #numberhexadecimal_rule
    |   BINARY                                          #numberbinary_rule
                ;

symbol: TOK_ID                                          #symbol_rule
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