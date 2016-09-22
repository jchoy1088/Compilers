grammar FreeLinguagem;




// GRAMATICA LIVRE DE CONTEXTO
raiz		:	(branch)*													;
branch		:	branch SIGNO branch | GER_NUM | PAR_OPN branch PAR_CLO		;



// GRAMATICA REGULAR
WS			:	[ \r\t\u000C\n]+ -> channel(HIDDEN)							;
GER_NUM		:	BIN_NUM | DEC_NUM | HEX_NUM | INT_NUM						;
INT_NUM		:	(DIGIT+ |  '-' DIGIT+)										;
BIN_NUM		:	BIN_DIGIT+ 'b'												;
HEX_NUM		:	[0][xX](DIGIT+|HEX_MIN+|HEX_MAY+)							;
DEC_NUM		:	[-+]?DIGIT+'.'?DIGIT+([eE][-+]?DIGIT+)?						;
DIGIT		:	('0'..'9')													;
HEX_MAY		:	('A'..'F')													;
HEX_MIN		:	('a'..'f')													;
BIN_DIGIT	:	[01]														;
SIGNO		:	'+' | '-' | '*' | '/' | 'ˆ'									;
STATUS		:	'status'													;
CLEAR		:	'clear'														;
PAR_OPN		:	'('															;
PAR_CLO		:	')'															;
