%{
#include "lexico1.h"
void error_lexico();
%}
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+
%%
[ \n\t]+                            ;
"--"(.*)[\n]                        ;
[ \t\r\n]     { }
"//".*        { }

"main"                              return MAIN;
begin                               return BEGINN;
end                                 return END;
read                                return READ;
write                               return WRITE;
{letra}({letra}|{digito}|_)*        return ID;
{entero}                            return INTLITERAL;
"("                                 return LPAREN;		
")"                                 return RPAREN;
";"                                 return SEMICOLON;
","                                 return COMMA;
":="                                return ASSIGNOP;
"+"                                 return PLUSOP;
"-"                                 return MINUSOP;
{entero}[.]{entero}                 return REALLIT;
.                                   error_lexico();

%%

void error_lexico()
{
  printf("\nERROR, símbolo no reconocido %s\n",yytext);
}

void main() {
    int i;
    while (i=yylex())
        printf("%d %s\n",i,yytext);
    printf("FIN DE ANALISIS LEXICO\n");
}
