lexico : lex.yy.c
	gcc lex.yy.c -lfl -o lexico
	
lex.yy.c : calculadora.l calculadora.h
	flex calculadora.l

clean :
	rm -f lex.yy.c lexico

run : lexico
	./lexico < entrada.txt