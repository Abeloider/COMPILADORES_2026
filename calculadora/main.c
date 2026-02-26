


    int main () {
        int token;
        if (argc != 2) {
            printf("Uso: %s fichero\n", argv[0]);
            exit(1);
        }
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            printf("No se puede abrir %s\n", argv[1]); 
            exit(2);
        }

        yyparse();
    }