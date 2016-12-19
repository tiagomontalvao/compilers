all: lula entrada.bf
	./lula < entrada.bf > gerado.cc
	./Gabarito/gabarito < gerado.cc
	g++ -o saida gerado.cc
	./saida

lex.yy.c: lula.lex
	lex lula.lex

y.tab.c: lula.y
	yacc -v lula.y

lula: lex.yy.c y.tab.c
	g++ -std=c++11 -o lula y.tab.c -lfl

mdc: mdc.bf
	./lula < mdc.bf > mdc.cc
	g++ -o mdc.out mdc.cc
	./mdc.out

multmatriz: multmatriz.bf
	./lula < multmatriz.bf > multmatriz.cc
	g++ -o multmatriz.out multmatriz.cc
	./multmatriz.out

concatstring: concatstring.bf
	./lula < concatstring.bf > concatstring.cc
	g++ -o concatstring.out concatstring.cc
	./concatstring.out


clean:
	rm y.tab.c lula lex.yy.c y.output
