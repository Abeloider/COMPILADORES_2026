lexico : lex.yy.c
	gcc lex.yy.c -lfl -o lexico
	
lex.yy.c : mini.l mimini
	flex mini.l

clean :
	rm -f lex.yy.c lexico

run : lexico
	./lexico < prueba.txt