minic : lex.yy.c miniC.tab.c listaSimbolos.c main.c
	gcc -g lex.yy.c miniC.tab.c listaSimbolos.c main.c -lfl -o minic

miniC.tab.c miniC.tab.h : miniC.y
	bison -d -v miniC.y

lex.yy.c : miniC.l miniC.tab.h
	flex miniC.l

clean :
	rm -f lex.yy.c miniC.tab.c miniC.tab.h minic

run : minic
	./minic prueba.txt