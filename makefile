all: lula entrada.cunha
	./lula < entrada.cunha > gerado.cc
	./Gabarito/gabarito < gerado.cc
	g++ -o saida gerado.cc
	./saida

lex.yy.c: lula.lex
	lex lula.lex

y.tab.c: lula.y
	yacc -v lula.y

lula: lex.yy.c y.tab.c
	g++ -std=c++11 -o lula y.tab.c -lfl

mdc: mdc.cunha
	./lula < mdc.cunha > mdc.cc
	g++ -o mdc.out mdc.cc
	./mdc.out

multmatriz: multmatriz.cunha
	./lula < multmatriz.cunha > multmatriz.cc
	g++ -o multmatriz.out multmatriz.cc
	./multmatriz.out

concatstring: concatstring.cunha
	./lula < concatstring.cunha > concatstring.cc
	g++ -o concatstring.out concatstring.cc
	./concatstring.out

referencia: referencia.cunha
	./lula < referencia.cunha > referencia.cc
	g++ -o referencia.out referencia.cc
	./referencia.out

opr_in_igual: opr_in_igual.cunha
	./lula < opr_in_igual.cunha > opr_in_igual.cc
	g++ -o opr_in_igual.out opr_in_igual.cc
	./opr_in_igual.out

switch: switch.cunha
	./lula < switch.cunha > switch.cc
	g++ -o switch.out switch.cc
	./switch.out

while_do-while: while_do-while.cunha
	./lula < while_do-while.cunha > while_do-while.cc
	g++ -o while_do-while.out while_do-while.cc
	./while_do-while.out

clean:
	rm y.tab.c lula lex.yy.c y.output
