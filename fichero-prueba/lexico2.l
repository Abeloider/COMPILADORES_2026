%{
#include "lexico1.h"
%}
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+

%%
[ \n\t]+                                    ;
"--"(.*)[\n]                                ;
begin                                       return BEGINN;
end                                         return END;
read                                        return READ;
write                                       return WRITE;
{letra}({letra}|{digito}|_)*                return ID;
{entero}                                    return INTLITERAL;
"("                                         return LPAREN;		
")"                                         return RPAREN;
";"                                         return SEMICOLON;
","                                         return COMMA;
":="                                        return ASSIGNOP;
"+"                                         return PLUSOP;
"-"                                         return MINUSOP;
{entero}[.]{entero}                         return REALLIT;
.                                           printf("Error en carácter %s",yytext );
%%