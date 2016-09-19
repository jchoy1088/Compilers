grammar FreeLinguagem;

expressao 
:	sem_oper | oper_basica | oper_par| oper_com | oper_par_dir | oper_par_esq
;

sem_oper
:	GER_NUM*
;

oper_basica
:	GER_NUM SIGNO+ GER_NUM
;

oper_esq
:	GER_NUM SIGNO
;

oper_dir
:	SIGNO GER_NUM
;

oper_par
:	SIGNO* PAR_OPN oper_basica PAR_CLO | oper_par SIGNO oper_par
;

oper_com
:	oper_esq oper_par | oper_par oper_dir
;


oper_par_dir
:	oper_par oper_dir | SIGNO* PAR_OPN oper_com PAR_CLO oper_dir | SIGNO* PAR_OPN oper_par_dir PAR_CLO
;

oper_par_esq
:	oper_esq oper_par | SIGNO* oper_esq PAR_OPN oper_com PAR_CLO | SIGNO* PAR_OPN oper_par_esq PAR_CLO
;



WS 
:	[ \r\t\u000C\n]+ -> channel(HIDDEN)
;

GER_NUM
:	BIN_NUM | DEC_NUM | HEX_NUM | INT_NUM
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

BIN_DIGIT
:	[01]
;

SIGNO
:	'*' | '/' | 'ˆ' | SIGNO_BAS
;

SIGNO_BAS
:	'+' | '-'
;

STATUS
:	'status'
;

PAR_OPN
:	'('
;

PAR_CLO
:	')'
;

CLEAR
:	'clear'
;