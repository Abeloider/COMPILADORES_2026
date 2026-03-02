calculadora : lex.yy.c calculadora.tab.c main.c
	gcc lex.yy.c calculadora.tab.c main.c -lfl -o calculadora

lex.yy.c : calculadora.l calculadora.tab.h
	flex calculadora.l

calculadora.tab.h calculadora.tab.c : calculadora.y
	bison -d -v calculadora.y

clean : 
	rm -f lex.yy.c calculadora calculadora.tab.*

run : calculadora entrada.txt
	./calculadora entrada.txt
