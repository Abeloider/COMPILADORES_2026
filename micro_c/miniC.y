%{
     #define _GNU_SOURCE
     #include <stdio.h>
     #include <stdlib.h>
     #include <string.h>
     #include <stdbool.h>
     #include <assert.h>
     #include "listaSimbolos.h"
     #include "listaCodigo.h"
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

     bool registros[10];
     void inicializaRegs();
     char *obtenerReg();
     void liberarReg(char *reg);
     ListaC expresion_num(char *num);
     ListaC expresion_id (char *id);
     ListaC expresion_bin(char *op, ListaC expr1, ListaC expr2);

%}

%code requires{
    #include "listacodigo.h"
}

%union {
  int num;
  ListaC codigo;
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
           VOID ID "(" ")" "{" body "}" { // comprobamos que el id es main
               if (strcmp($3, "main") != 0) {
                   printf("Error en linea %d: la funcion debe llamarse 'main'\n", yylineno);
                   errores++;
               }
           }
           {if (errores ==0) {
               imprimirLS();}
           liberaLS(l);}
          ;


body : body declaration
     | body statement
     | %empty
     ;

declaration : VAR {t = VARIABLE;} tipo id_list ";" 
            | CONST {t = CONSTANTE;} tipo id_list ";"
            ;
            
tipo : INT

id_list : id_decl 
        | id_list "," id_decl 
        ;
id_decl : ID {
             // declaramos una funcion con dos parametros
             declarar_id($1,t); 
          }
        | ID "=" expression {
          declarar_id($1,t); 
          }
        ;

statement : ID "=" expression ";" {
                PosicionLista p = buscaLS(l, $1);
                // comprobamos que el id existe y no es una constante
                if (p == finalLS(l)) {
                    printf("Error en linea %d: %s no declarado\n", yylineno, $1);
                    errores++;
                } else {
                    Simbolo s = recuperaLS(l, p);
                    if (s.tipo == CONSTANTE) {
                        printf("Error en linea %d: %s es una constante\n", yylineno, $1);
                        errores++;
                    }
                }
            }
          | "{" statement_list "}"
          | IF "(" expression ")" statement ELSE statement
          | IF "(" expression ")" statement %prec NOELSE
          | WHILE "(" expression ")" statement
          | PRINT "(" print_list ")" ";"
          | READ "(" read_list ")" ";"
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
read_list : ID { 
                PosicionLista p = buscaLS(l, $1);
                if (p == finalLS(l)) {
                    printf("Error en linea %d: %s no declarado\n", yylineno, $1);
                    errores++;
                } else {
                    Simbolo s = recuperaLS(l, p);
                    if (s.tipo == CONSTANTE) {
                        printf("Error en linea %d: %s es una constante\n", yylineno, $1);
                        errores++;
                    }
                }
            }
          | read_list "," ID {
               // comprobamos que el id existe y no es una constante
                PosicionLista p = buscaLS(l, $3);
                if (p == finalLS(l)) {
                    printf("Error en linea %d: %s no declarado\n", yylineno, $3);
                    errores++;
                } else {
                    Simbolo s = recuperaLS(l, p);
                    if (s.tipo == CONSTANTE) {
                        printf("Error en linea %d: %s es una constante\n", yylineno, $3);
                        errores++;
                    }
                }
            }
          ;

expression : expression "+" expression {$$=expresion_bin("add", $1,$3);}
           | expression "-" expression {$$=expresion_bin("res", $1,$3);}
           | expression "*" expression {$$=expresion_bin("sum", $1,$3);}
           | expression "/" expression {$$=expresion_bin("div", $1,$3);}                                   
           | "-" expression %prec UMINUS {}
           | "(" expression ")" {}
           | ID {
               // comprobamos que el id existe y no es una constante
                PosicionLista p = buscaLS(l, $1);
                if (p == finalLS(l)) {
                    printf("Error en linea %d: %s no declarado\n", yylineno, $1);
                    errores++;
                }
            }
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

void inicializaRegs(){
    for(int i=0; i<10; i++) 
        registros[i] = false; 
}

char *obtenerReg(){
    //buscar registro $tx libre
    for(int i=0; i<10; i++){
        if(registros[i]=false){
            registros[i]=true;
            char *reg;
            asprintf(&reg, "$t%d", i);
            return reg;
        }
    }
    printf("Error: registros agotados\n");
    exit(1);
}
void liberarReg(char *reg){
    //reg == &tx
    assert(reg[0] == '$');
    assert(reg[1] == 't');
    int idx = reg[2] - '0';
    assert (idx >=0); 
    assert (idx <=0); 
    registros[idx] = false;  
}

ListaC expresion_num(char*num) {
    ListaC codigo = creaLC();
    Operacion o; 
    o.op = "li"; 
    o.res = obtenerReg(); 
    o.arg1 = num; 
    o.arg2 = NULL; 
    insertaLC(codigo, finalLC(codigo),o); 
    guardaResLC(codigo,o.res); 
    return codigo; 
}

ListaC expresion_id(char*id) {
    ListaC codigo = creaLC();
    Operacion o; 
    o.op = "lw"; 
    o.res = obtenerReg(); 
    asprintf(&(o.arg1), "_%s", id);
    o.arg1 = id; 
    o.arg2 = NULL; 
    insertaLC(codigo, finalLC(codigo),o); 
    guardaResLC(codigo,o.res); 
    return codigo; 
}

ListaC expression_bin(char *op, ListaC expr1, ListaC expr2) {
   ListaC codigo; 
   codigo = expr1; 
   concatenaLC(codigo, expr2);
   Operacion o;
   o.op=op;
   o.res = recuperaResLC(expr1); 
   o.arg1= recuperaResLC(expr1); 
   o.arg2= recuperaResLC(expr2); 
   insertaLC(codigo, finalLC(codigo),o); 
   liberarReg(o.arg2);
   return codigo; 
}

void imprimir_lc(ListaC codigo1){
    PosicionListaC p = inicioLC(codigo1);
    Operacion oper; 
    while(p!=finalLC(codigo1)){
        oper=recuperaLC(codigo1,p);
        printf("%s", oper.op);
        if(oper.res) printf(" %s", oper.res);
        if(oper.arg1) printf(" %s", oper.arg1);
        if(oper.arg2) printf(" %s", oper.arg2);
        printf("\n");
        p=siguienteLC(codigo1,p);
        
    }
}