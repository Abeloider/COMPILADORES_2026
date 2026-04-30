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
     int declarar_str(char *str);
     int contador_cadenas=0; // contador para cadenas
     void imprimirLS();
     void verificar_id(char *id, bool es_var);
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
%token <cadena> STRING "string"
%token <cadena> ID "identifier"


/* Tipo de dato de los no terminales de la gramática */
%type <codigo> expression statement body declaration id_list id_decl statement_list print_list print_item read_list

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


program : { l = creaLS(); 
            inicializaRegs();} 
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

declaration : VAR  tipo id_list ";" {$$=$3;}
            | CONST  tipo id_list ";" {$$=$3;}
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
                // generacion de codigo de asignacion
                verificar_id($1, true); {// comprobamos que el id existe y no es una constante
                if (errores == 0) {
                    $$ = $3; // el codigo de la expresion
                    Operacion o; 
                    o.op = "sw";
                    o.res = recuperaResLC($3); // el resultado de la expresion
                    asprintf(&(o.arg1), "_%s", $1); // la direccion de la variable
                    o.arg2 = NULL;
                    insertaLC($$, finalLC($$), o); // añadimos la operacion al codigo
                    liberarReg(o.res); // liberamos el registro usado por la expresion
                }
                } 
            }
          | "{" statement_list "}" {
            if (errores==0){
                $$ = $2;
            }}
          | IF "(" expression ")" statement ELSE statement
          | IF "(" expression ")" statement %prec NOELSE
          | WHILE "(" expression ")" statement
          | PRINT "(" print_list ")" ";"
          | READ "(" read_list ")" ";"
          | error ";"
;

statement_list : statement_list statement {
                    
}
                
               | %empty
               ;

print_list : print_item
           | print_list "," print_item
           ;

print_item : expression {$$ = $1;}
          | STRING {int idx = declarar_str($1);
            if(errores==0){
             $$=creaLC(); 
             Operacion o;
                o.op = "li"; 
                o.res = "$v0";
                o.arg1 = "4"; 
                o.arg2 = NULL;
                insertaLC($$, finalLC($$), o);
                o.op = "la";
                o.res = "$a0";
                asprintf(&(o.arg1), "_str%d", idx);
                o.arg2 = NULL;
                insertaLC($$, finalLC($$), o);
                o.op = "syscall";
                o.res = NULL;
                o.arg1 = NULL;
                o.arg2 = NULL;
                insertaLC($$, finalLC($$), o);
            }}
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
               verificar_id($1, false);
               $$ = expresion_id($1); // generamos el codigo de acceso a la varible

                PosicionLista p = buscaLS(l, $1);
                if (p == finalLS(l)) {
                    printf("Error en linea %d: %s no declarado\n", yylineno, $1);
                    errores++;
                }
            }
           | NUM {
                $$ = expresion_num($1); // generamos el codigo de cargar el numero en un registro
           }
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


int declarar_str(char *str) {
    PosicionLista p = buscaLS(l, str);
     if (p != finalLS(l)) {
        Simbolo s = recuperaLS(l, p);
        return s.valor; // devolvemos el indice de la cadena ya declarada
     }
     else {
          Simbolo s;
          s.nombre = str; 
          s.valor = contador_cadenas++;
          s.tipo = CADENA;
          insertaLS(l, finalLS(l), s);
          contador_cadenas++;
          return s.valor; // devolvemos el indice de la nueva cadena
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

void verificar_id(char *id, bool es_var){
    PosicionLista p = buscaLS(l, id);
    if (p == finalLS(l)) {
            printf("Error en linea %d: %s no declarado\n", yylineno, id);
            errores++;
    }else{
        if(es_var){
            Simbolo s = recuperaLS(l, p);
            if (s.tipo == CONSTANTE) {
                printf("Error en linea %d: %s es una constante\n", yylineno, id);
                errores++;
            }
        } 
    }
}

char *nuevaEtiqueta() {
 char *aux;
 asprintf(&aux,"$l%d",contador_cadenas++);
 return aux;
}

void inicializaRegs(){
    for(int i=0; i<10; i++) 
        registros[i] = false; 
}

char *obtenerReg(){
    //buscar registro $tx libre
    for(int i=0; i<10; i++){
        if(registros[i]==false){
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
    assert (idx >= 0); 
    assert (idx <= 9); 
    registros[idx] = false;  
}

ListaC statement_while(ListaC expr, ListaC stat) {
    char *etiq_inicio = nuevaEtiqueta();
    char *etiq_fin = nuevaEtiqueta();
    Operacion o; 
    o.op = etiq_inicio;
    o.res = o.arg1 = o.arg2 = NULL;
    ListaC codigo = creaLC();
    insertaLC(codigo, finalLC(codigo), o);
    concatenaLC(codigo, expr); // viene toda la expresion con su codigo 
    o.op = "beqz";
    o.res = recuperaResLC(expr); // el resultado de la expresion
    o.arg1 = etiq_fin; // saltamos al final si la expresion es falsa
    o.arg2 = NULL;
    insertaLC(codigo, finalLC(codigo), o);
    concatenaLC(codigo, stat); // viene todo el codigo del statement // parte verde 
    o.op="b";
    o.res = etiq_inicio; // volvemos al inicio del bucle
    o.arg1 = o.arg2 = NULL;
    insertaLC(codigo, finalLC(codigo), o);
    o.op = etiq_fin; // etiqueta de fin del bucle
    o.res = o.arg1 = o.arg2 = NULL;
    insertaLC(codigo, finalLC(codigo), o);
    liberarReg(recuperaResLC(expr)); // liberamos el registro usado por la expresion
    liberaLC(expr); // liberamos el codigo de la expresion
    liberaLC(stat); // liberamos el codigo del statement
    return codigo;

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

ListaC expresion_bin(char *op, ListaC expr1, ListaC expr2) {
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
        if(oper.op[0]=='$'){

        }
        else{
        printf("%s", oper.op);
        if(oper.res) printf(" %s", oper.res);
        if(oper.arg1) printf(" %s", oper.arg1);
        if(oper.arg2) printf(" %s", oper.arg2);
        }
        printf("\n");
        p=siguienteLC(codigo1,p);
        
    }
}