grammar Numbers;


/*
// Descomente para gerar codigo em c#
options {
    language=CSharp;
}

*/
number: BINARY; 

NEWLINE
:	[\r\n ]+
;

BIN_DIGIT
:	[01]
;

DIGIT
:	('0'..'9')
;

HEX_MAY
:	('A'..'F')
;

HEX_MIN
:	('a'..'f')
;

BIN_NUM
:	BIN_DIGIT+ 'b'
;

DEC_NUM
:	[-+]?[0-9]+'.'?[0-9]+([eE][-+]?[0-9]+)?
;

HEX_NUM
:	[0][xX](DIGIT+|HEX_MIN+|HEX_MAY+)
;

INT_NUM
:	(DIGIT+ |  '-' DIGIT+)
;

SIGNO
:	'*'|'+'|'/'|'-'|'ˆ'
;

STATUS
:	'status'
;

CLEAR
:	'clear'
;