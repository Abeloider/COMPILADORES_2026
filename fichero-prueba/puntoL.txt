%{
    /*CODIGO VERBATIM básicamente codigo literal en C*/ 
    #include <stdio.h>
    #include <stdlib.h>
    #include "miniC.tab.h"
    
    int inicio_comentario = 0;
    int errores=0; // hacemos un contador de errores errores++ 
    long long MAX_ENTERO = 21474836487; // 

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


"print"                       { return PRINT; }                            
"var"                         { return VAR; }
"const"                       { return CONST; }
"int"                         { return INT; }
"if"                          { return IF; }
"else"                        { return ELSE; }
"while"                       { return WHILE; }
"read"                        { return READ; }
"void"                        { return VOID; }

{L}({L}|{D})*               { if(yyleng<=32){
                                yylval.cadena = strdup(yytext);
                                return ID;
                                } else {
                                    printf("Error léxico: identificador demasiado largo en linea %d\n", yylineno);
                                    errores++; 
                                 }
                                 yylval.cadena = strdup(yytext);
                                 return ID;                        
                            }
                             
";"                         { return PYC; } 
"="                         { return IGU; } 
"+"                         { return MAS; }
"-"                         { return MEN; } 
"/"                         { return DIV; }
"*"                         { return POR; }
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
                                yylval.cadena = strdup(yytext);
                                return NUM; 
 }
 
\"([^"\n\\]|\\["ntr])*\"    { 
                                 yylval.cadena = strdup(yytext);
                                 return STRING; }
\"([^"\n\\]|\\[\"ntr])*     { printf("Error léxico: Cadena de caracteres no cerrada en línea %d %s\n",
                                        yylineno, yytext);
                                        errores++;}
.                           { printf("Error léxico: símbolo no reconocido en la linea %d %s\n",
                                        yylineno, yytext);
                                        errores++;} 

{panico}                   { printf("Error léxico: símbolos no reconocido en la linea %d %s\n",
                                        yylineno, yytext); }

%%
