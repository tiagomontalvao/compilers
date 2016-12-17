all: trabalho entrada.bf
	./trabalho < entrada.bf > gerado.cc
	./Gabarito/gabarito < gerado.cc
	g++ -o saida gerado.cc
	./saida

lex.yy.c: trabalho.lex
	lex trabalho.lex

y.tab.c: trabalho.y
	yacc -v trabalho.y

trabalho: lex.yy.c y.tab.c
	g++ -std=c++11 -o trabalho y.tab.c -lfl

clean:
	rm y.tab.c trabalho lex.yy.c y.output
