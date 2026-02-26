lexico : lex.yy.c
	gcc lex.yy.c -lfl -o lexico
	
lex.yy.c : micro_c.l micro_c.h
	flex micro_c.l

clean :
	rm -f lex.yy.c lexico

run : lexico
	./lexico < entrada.txt