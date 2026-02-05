%{
    /*CODIGO VERBATIM básicamente codigo literal en C*/ 
    #include <stdio.h>
    #include "micro_c.h"
    int inicio_comentario = 0;

%}

/*DEFINICIONES DE MACROS DE EXPRESIONES REGULARES*/

L   [a-zA-Z_$]
D   [0-9]
panico [^a-zA-Z_$'0-9'\.*/ \t\n\r"(){}]+

/*opciones de flex*/
%option yylineno

/*condicion de contexto para comentario multilinea*/
%x comentario

%%

[ \t\r\n]                   { }
"//".*                      { }
"/*"                        { BEGIN (comentario);
                            inicio_comentario = yylineno; }
<comentario>.|\n            {}
<comentario>"*/"            { BEGIN (INITIAL); }
<comentario><<EOF>>         { printf("Error: comentario desde %d sin cerrar al final\n",
                                inicio_comentario);
                             return 0; 
                            }


";"                         { return PYC; } 
"print"                     { return PRI; }
"main"                      { return MAI; }
{L}({L}|{D})*               { return IDE; }
"="                         { return IGU; }
"+"                         { return SUM; }
"-"                         { return RES; } 
"/"                         { return DIV; }
"*"                         { return MUL; }
"("                         { return PAI; }
")"                         { return PAD; }
"{"                         { return LLI; }
"}"                         { return LLD; }
","                         { return COM; }
{D}+                        { return NUM; }
\"([^"\n\\]|\\["ntr])*\"    { return CAD; }
\"([^"\n\\]|\\[\"ntr])*     { printf("Cadena de caracteres no cerrada en línea %d %s\n",
                                        yylineno, yytext); }
.                           { printf("Error: simbolo no reconocido %d %s\n",
                                        yylineno, yytext); } 

{panico}                   { printf("Error en linea %d %s\n",
                                        yylineno, yytext); }

%%

int main(int argc, char *argv[]) {
       int token;
        while((token=yylex()) != 0) {
            printf("Token: <%d, %s>\n", token, yytext);
    }
}
