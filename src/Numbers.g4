grammar Numbers;

STATUS
:	'for(int i = 0; i < stk.size(); i++){System.out.println(stkNumbers.get(i));}'
;

RESET
:	'stk.clear();'
;

/*
// Descomente para gerar codigo em c#
options {
    language=CSharp;
}
*/

number: BINARY; // precisa ao menos uma regra de gramática
                 // ignorar isso por hora

NEWLINE
:	[\r\n ]+
;

/*
DIGIT
:	'0'..'9'
;
*/

BINARY
:	BIN_DIGIT+ 'b'
; // Sequencia de digitos seguida de b  10100b

BIN_DIGIT
:	[01]
;


DECIMAL
:	[0-9]+(.[0-9][0-9]?)?[-+]?'e'?[0-9]+
;

HEXADECIMAL
:	[0][xX][0-9a-fA-F]+
;

PLUS
:	'+'
;

MULTIP
:	'*'
;

MINUS
:	'-'
;

DIVIS
:	'/'
;

POTEN
:	'ˆ'
;




/*
Otro caso
DECIMAL
[0-9]+(.[0-9][0-9]?)?[-+]?e?[0-9]+
HEXADECIMAL
(?:0[xX])?[0-9a-fA-F]+
*/