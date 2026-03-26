%{
    #include <stdio.h>
    #include <stdlib.h>
    extern int yylex();
    extern int yylineno;
    extern int errores;
    void yyerror(const char *msg);
    int regs[10];    
    void write_reg(char *reg, int value);
    int read_reg(char *reg);
    void print_regs();
    void init_regs();
%}

%union {
  int num;
  char *reg;
}

%token MAS "+"
%token MEN "-"
%token POR "*"
%token DIV "/"
%token <num> NUM "number"
%token PAI "("
%token PAD ")"
%token PYC ";"
%token IGU "="
%token <reg> REG "register"

/* Tipo de dato de los no terminales de la gramática */
%type <num> expr

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

/* Hay un conflicto d/r en if-ifelse */
%except 

%%

program : { init_regs(); } line { print_regs(); }
        ;

line : REG "=" expr ";" { printf("L->R[%s]=E;\n", $1);  
                              write_reg($1,$3);
                        }
     | line REG "=" expr ";" { printf("L->L R[%s]=E;\n", $2);
                              write_reg($2,$4);
                        }
     | error ";"     {  }
     ;

expr : expr "+" expr { printf("E->E+E\n"); $$ = $1+$3; }
     | expr "-" expr { printf("E->E-E\n"); $$ = $1-$3; }
     | expr          { printf("E->E\n"); $$ = $1; }  
     | expr "*" expr { printf("E->E*E\n"); $$ = $1 * $3; }
     | expr "/" expr { printf("E->E/E\n"); 
                       if ($3 == 0) {
                         printf("División por 0 en linea %d\n",
                                yylineno);
                         exit(1);
                       }
                       $$ = $1 / $3;
                     }
     | expr          { printf("T->F\n"); $$ = $1; }
     | NUM           { printf("E->num (%d)\n", $1); $$ = $1; }
     | REG           { printf("E->REG\n"); $$ = read_reg($1); }
     | "(" expr ")"  { printf("E->(E)\n"); $$ = $2; }
     | "-" expr %prec UMINUS { printf("E->-F\n");  $$ = -$2; }
     ;
%%

void yyerror(const char *msg) {
    printf("Error sintáctico en linea %d: %s\n", yylineno, msg);
    errores++;
}

void write_reg(char *reg, int value) {
     // reg = "r[0-9]"
     int idx = reg[1] - '0';
     regs[idx] = value;
}

int read_reg(char *reg) {
     int idx = reg[1] - '0';
     return regs[idx];
}

void print_regs() {
     for (int i = 0; i < 10; i++) {
          printf("r%d = %d\n", i, regs[i]);
     }
}

void init_regs() {
     for (int i = 0; i < 10; i++) 
          regs[i] = 0;
}