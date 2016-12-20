Que Deus tenha misericórdia desta nação.

Depoimentos
	1. seed é integro;
	2. a é delação de [3][4] corruptos;
	3. b é delação de [4][2] corruptos;
	4. c é delação de [3][2] corruptos;
	5. i é integro;
	6. j é integro;
	7. k é integro;
	8. aux é integro;

PEC de integros pseudo_random;
Depoimentos
	1. aux é integro;
Príncipe
	
	seed recebe (8253729 * seed + 2396403);
	aux recebe (seed mod 32767 + 32767) mod 32767;
	desvia aux;

Suíço;

PEC de vento imprime( delação de [3][2] corruptos m; integros l, c );
Depoimentos
	1. i é integro;
	2. j é integro;
Príncipe
	Para i recebe 0 até l-1 faça {
		Para j recebe 0 até c-1 faça {
			Como printa, deputado? m[i][j];
			Como printa, deputado? ' \t';
		}
		Como printa, deputado? +n;
	}
Suíço;

PEC de vento multiplica( delação de [3][4] corruptos a; delação de [4][2] corruptos b;
						 integros lin_a, col_a, lin_b, col_b; delação de [3][2] corruptos c);

Depoimentos
	1. i é integro;
	2. j é integro;
	3. k é integro;
Príncipe
	
	Se ( lin_b != col_a ) rouba {
		Como printa, deputado? 'Matrizes incompativeis para multiplicação' +n  ;
		exit;
	}

	Para i recebe 0 até lin_a-1 faça {
		Para j recebe 0 até col_b-1 faça {
			c[i][j] recebe 0;
			Para k recebe 0 até lin_b-1 faça {
				c[i][j] recebe c[i][j] + (a[i][k] * b[k][j]);
			}
		}
	}
Suíço;



Príncipe
	seed recebe 5323;
	Para i recebe 0 até 2 faça {
		Para j recebe 0 até 3 faça {
			a[i][j] recebe pseudo_random() mod 10;
		}
	}
	Para i recebe 0 até 3 faça {
		Para j recebe 0 até 1 faça {
			b[i][j] recebe pseudo_random() mod 10;
		}
	}

	multiplica( a, b, 3, 4, 4, 2, c );
    imprime( c, 3, 2 );
    imprime( c, 3, 3 );

Suíço.
