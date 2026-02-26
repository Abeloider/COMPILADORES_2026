%{
#include <stdio.h>
extern int isdigit();
int yylex (void);
void yyerror (char const *);

%}

%union 
{
    int num;
    char* reg; 

}

%token   NUM "number"
%token   PYC ";"
%token   DIV "/" 
%token   MUL "*"
%token   SUM "+"
%token   RES "-"
%token   PAI "("
%token   PAD ")"
%token   IGU "="
%token   REG "register"


%define parse.error verbose


%%
line : expr ";"      {printf("L->R=E;\n", $1);}
     | line expr ";" {printf("L->L R=E;\n", $2); }
     | error ';' {}
     ;

expr :	expr '+' term	{printf("E -> E + T \n"); $$ = $1 + $3;}
        expr '-' term	{printf("E -> E  -T \n"); $$ = $1 - $3;}
	 |	term			{printf("E-> T\n"); $$ = $1;}
	 ;

term :	term '*' fact	{printf("T -> T * F \n"); $$ = $1 * $3;}
     |	term '/' fact	{printf("T -> T / F \n");
                                if ($3 == 0) {
                                    printf("Division por 0 en linea %d\n", yylineno);
                                    exit(1);
                                }
                                $$ = $1 / $3;
                                }
	 |	fact			{printf("T -> F 	\n"); $$ = $1;}
	 ;

fact : NUM             {printf("F -> num (%d)\n", $1); $$ = $1;}
     | REG             {printf("F -> REG (%d)\n"); $$ = 0;}
     |	'(' expr ')'   {printf("F-> (E) \n"); $$ = $2;}
     | "-" fact        {printf("F -> -F\n"); $$ = -$2;}
	 ;


%%

void yyerror (char const *s)
     {
       fprintf (stderr, "%s\n", s);
       errores++;
     }


int yylex() {
	int c;
	while ((c = getchar ()) == ' ' || c == '\t')
         ;
	
	if (isdigit(c)) {
		yylval=c-'0';
		return DIGITO;
	}
	
	return c;
}

int main (void) {
	
	return yyparse();
  
}