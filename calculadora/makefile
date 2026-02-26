calculadora : lex.yy.c calculadora.tab.c main.c
	gcc lex.yy.c calculadora.tab.c -lfl -o calculadora
	
lex.yy.c : calculadora.l calculadora.h
	flex calculadora.l

calculadora.tab.h calcularadora.tab.c : calculadora.y
	bison -d calculadora.y
	
clean :
	rm -f calculadora calculadora.tab.*

run : calculadora entrada.txt
	./calculadora < entrada.txt