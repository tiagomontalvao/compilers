all: trabalho entrada.cc
	./gabarito < entrada.cc

lex.yy.c: trabalho.lex
	lex trabalho.lex

y.tab.c: trabalho.y
	yacc trabalho.y

trabalho: lex.yy.c y.tab.c
	g++ -o gabarito y.tab.c -lfl
