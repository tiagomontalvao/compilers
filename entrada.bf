Que Deus tenha misericórdia desta nação.

Depoimentos
  1. a é integro;
  2. b é integro;
  3. c é integro;
  4. v1 é delação de [10] integros;
  5. v2 é delação de [10] integros;
  6. i é integro;


// Função que recebe parâmetros por cópia e referência e retorna uma string
PEC de cadeia bla( ref integro a; integro b; integro c );
Príncipe
	a recebe 5;
	desvia 'ble';
Suíço;

Príncipe

	// Testa passagem por referência
	a recebe 1;
	b recebe 2;
	b recebe 3;
	Como printa, deputado? a +n;
	Como printa, deputado? bla( a, b, 3 ) +n;
	Como printa, deputado? a +n;

	// Linha abaixo dá erro (constante passada por referẽncia)
	// Como printa, deputado? bla( 1, b, c ) +n;

	// Inicializa vetores
	For i recebe 0 To 9 Do
		v1[i] recebe i;
	For i recebe 0 To 9 Do
		v2[i] recebe i;

	// Operadores "foi citado em" (in), == e != para vetores
	Como printa, deputado? '5 foi citado em v1 ';
	Como printa, deputado? 5 foi citado em v1 +n;
	Como printa, deputado? '10 foi citado em v1 ';
	Como printa, deputado? 10 foi citado em v1 +n;
	Como printa, deputado? 'v1 == v2 ';
	Como printa, deputado? v1 == v2 +n;


Suíço.