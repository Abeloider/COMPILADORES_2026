%{
    #include "calculadora.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    int errores = 0;    
%}

%option yylineno

%%
[ \n\r\t]+  { }
"+"         { return MAS; }
"-"         { return MEN; }
"*"         { return POR; }
"/"         { return DIV; }
[0-9]+      { yylval.num = atoi(yytext); return NUM; }
"("         { return PAI; }
")"         { return PAD; }
";"         { return PYC; }
"="         { return IGU; }
"r"[0-9]    { yylval.reg = strdup(yytext); return REG; }
.           { printf("Error lexico en linea %d: %s\n",
                    yylineno, yytext);
              errores++;
            }

%%