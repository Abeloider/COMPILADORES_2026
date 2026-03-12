%{
     #include <stdio.h>
     #include <stdlib.h>
     #include "listaSimbolos.h"
     extern int yylex();
     extern int yylineno;
     extern int errores;
     // funcion de error
     void yyerror(const char *msg);
     // lista simbolos 
     Lista l; 
     /*declaracion de la lista de simbolos*/
     void declarar_id(char *id, Tipo t); 
     void imprimirLS();
     //variable para deteerminar si el id es VAR o CONST 
     Tipo t;

%}

%union {
  int num;
  char *cadena;
}

%token MAS "+"
%token MEN "-"
%token POR "*"
%token DIV "/"
%token <cadena> NUM "number"
%token PAI "("
%token PAD ")"
%token PYC ";"
%token IGU "="
%token LLI "{"
%token LLD "}"
%token COM ","
%token <cadena> REG "register"
%token PRINT "print"
%token VAR "var"
%token CONST "const"
%token INT "int"
%token IF "if"
%token ELSE "else"
%token WHILE "while"
%token READ "read"
%token VOID "void"
%token STRING "string"
%token <cadena> ID "identifier"


/* Tipo de dato de los no terminales de la gramática */
%type <num> expression

/* Asociatividad y precedencia 
     % left asociatividad izquierda 
     % right asociatividad derecha
     %nonasoc: no debe tener asociatividad 2+2+2 (error sintac)
     Misma precedencia y asociatividad en la misma linea
     Mayor precedencia en lineas sucesivas/inferiores

     %precedence: solo define preferencia no asociatividad
*/
%left "+" "-"
%left "*" "/"
%precedence UMINUS

/* Resolucion de conflicto if if-else */
%precedence NOELSE
%precedence ELSE

/* Activar mensajes de error detallados */
%define parse.error verbose

/* Activar trazas */
%define parse.trace



/*Evitar el warning de if / if-else
Por defecto bison desplaza en el conflicto d/r
y lo resuelve de este modo correctamente*/

// %expect 1


%%


program : {l = creaLS(); }
           VOID ID "(" ")" "{" body "}"
           {if (errores ==0) {
               imprimirLS();}
           liberaLS(l);}
          ;


body : body declaration
     | body statement
     | %empty
     ;

declaration : VAR {t = VARIABLE;} id_list ";" 
            | CONST {t = CONSTANTE;} tipo id_list ";"
            ;
            
tipo : INT

id_list : id_decl 
        | id_list "," id_decl 
        ;
id_decl : ID {
             // declaramso una funcion con dos parametros 
             declarar_id($1,t); 
          }
        | ID "=" expression {
          declarar_id($1,t); 
          }
        ;

statement : ID "=" expression ";"
          | "{" statement_list "}"
          | IF "(" expression ")" statement ELSE statement
          | IF "(" expression ")" statement %prec NOELSE
          | WHILE "(" expression ")" statement
          | PRINT "(" print_list ")" ";"
          | READ "(" REA_list ")" ";"
          | error ";"
;

statement_list : statement_list statement
               | %empty
               ;

print_list : print_item
           | print_list "," print_item
           ;

print_item : expression 
          | STRING
          ; 
REA_list : ID
          | REA_list "," ID
          ;

expression : expression "+" expression {}
           | expression "-" expression {}
           | expression "*" expression {}
           | expression "/" expression {}
           | "-" expression %prec UMINUS {}
           | "(" expression ")" {}
           | ID {}
           | NUM {}
           ;


%%

void yyerror(const char *msg) {
    printf("Error sintáctico en linea %d: %s\n", yylineno, msg);
    errores++;
}

void declarar_id(char *id, Tipo t) {
     PosicionLista p = buscaLS(l, id);
     if (p != finalLS(l)) {
          printf ("error en linea %d: %s redeclarado\n", yylineno, id);
          errores++;
     }
     else {
          Simbolo s;
          s.nombre = id; 
          s.valor = 0;
          s.tipo = t;
          insertaLS(l, finalLS(l), s);
     }
}

void imprimirLS() {
     printf(".data\n");
     PosicionLista p = inicioLS(l);
     while (p != finalLS(l)) {
          Simbolo aux = recuperaLS(l, p);
          // el guion bajo es para evitar problemas con nombres de variables que no son validos en ensamblador
          printf("_%s: .word %d\n", aux.nombre, aux.valor);
          p = siguienteLS(l, p);
     }
}
