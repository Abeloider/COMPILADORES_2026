%{
    /*CODIGO VERBATIM básicamente codigo literal en C*/ 
    #include <stdio.h>
    #include <stdlib.h>
    #include "micro_c.h"
    
    int inicio_comentario = 0;
    int errores=0; // hacemos un contador de errores errores++ 
    int MAX_ENTERO = 2147483648; 

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
<comentario>.|\n            { yymore(); }
<comentario>"*/"            { BEGIN (INITIAL); }
<comentario><<EOF>>         { printf("Error: comentario desde %d sin cerrar al final\n",
                                inicio_comentario);
                             return 0; 
                            }


"print"                       { return PRI; }                            
"var"                         { return VAR; }
"const"                       { return CON; }
"int"                         { return INT; }
"if"                          { return IF; }
"else"                        { return ELS; }
"while"                       { return WHI; }
"read"                        { return REA; }
"void"                        { return VOI; }

{L}({L}|{D})*               { if(yyleng<=32){
                                printf("Identificador %d\n", yyleng);
                                return IDE;
                                } else {
                                    printf("Error léxico: identificador demasiado largo en linea %d\n", yylineno);
                                    errores++; 
                                 }                            
                            }
                             
";"                         { return PYC; } 
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

{D}+                        { 
                                long long entero = strtoll(yytext, NULL, 10);
                                if (entero > MAX_ENTERO) {
                                    printf("Entero %s muy grande en la linea %d|\n",yytext ,yylineno);
                                }
                                printf("Entero: %lld\n", entero);
                                return NUM; 
 }
\"([^"\n\\]|\\["ntr])*\"    { return CAD; }
\"([^"\n\\]|\\[\"ntr])*     { printf("Cadena de caracteres no cerrada en línea %d %s\n",
                                        yylineno, yytext); }
.                           { printf("Error: simbolo no reconocido %d %s\n",
                                        yylineno, yytext); } 

{panico}                   { printf("Error en linea %d %s\n",
                                        yylineno, yytext); }

%%
