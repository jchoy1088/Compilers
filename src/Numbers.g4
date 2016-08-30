grammar Numbers;

/*
// Descomente para gerar codigo em c#
options {
    language=CSharp;
}
*/

number: BINARY; // precisa ao menos uma regra de gramática
                 // ignorar isso por hora

NEWLINE : [\r\n ]+;

BINARY : BIN_DIGIT+ 'b' ; // Sequencia de digitos seguida de b  10100b

BIN_DIGIT : [01];
