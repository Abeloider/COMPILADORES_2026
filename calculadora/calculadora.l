%{
    /*CODIGO VERBATIM básicamente codigo literal en C*/ 
    #include <stdio.h>
    #include "calculadora.h"

%}

/*DEFINICIONES DE MACROS DE EXPRESIONES REGULARES*/

L   [a-zA-Z]
D   [0-9]
/*opciones de flex*/
%option yylineno


%%

[ \t\r\n]     { }
"//".*        { }
";"                 { return PYC; } 
"print"             { return PRI; }
{L}({L}|{D})*       { return IDE; }
"="                 { return IGU; }
"+"                 { return SUM; }
"-"                 { return RES; } 
"/"                 { return DIV; }
"*"                 { return MUL; }
"("                 { return PAI; }
")"                 { return PAD; }
{D}+                { return NUM; }

.             { printf("Error: simbolo no reconocido %d %s\n", yylineno, yytext); } 

%%


int main(int argc, char *argv[]) {
       int token;
        while((token=yylex()) != 0) {
            printf("Token: <%d, %s>\n", token, yytext);
    }
}
