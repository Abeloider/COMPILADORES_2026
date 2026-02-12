#include <stdio.h>
#include <stdlib.h>

extern char *yytext; 
extern int yylex(); 
extern FILE *yyin; 


int main(int argc, char *argv[]) {
       int token;

       if (argc != 2) {
        printf("uso: %s fichero\n", argv[0]);
         exit(1);
        }
        yyin = fopen(argv[1], "r"); 
        if (yyin == NULL) {
            printf("No se puede abrir %s\n el archivo", argv[1]);   
            exit(2);
        }
        while((token=yylex()) != 0) {
            printf("Token: <%d, %s>\n", token, yytext);
    }
}