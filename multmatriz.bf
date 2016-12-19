Que Deus tenha misericórdia desta nação.

Políticos
	1. seed é integro;
	2. a é delação de [3][4] integros;
	3. b é delação de [4][2] integros;
	4. c é delação de [3][2] integros;
	5. i é integro;
	6. j é integro;
	7. k é integro;
	8. aux é integro;

PEC de integros pseudo_random();
Políticos
	1. aux é integro;
Príncipe
	
	seed recebe (8253729 * seed + 2396403);
	aux recebe (seed mod 32767 + 32767) mod 32767;
	desvia aux;

Suíço;

PEC de vento imprime( delação de [3][2] integros m; integros l, c );
Políticos
	1. i é integro;
	2. j é integro;
Príncipe
	For i recebe 0 To l-1 Do {
		For j recebe 0 To c-1 Do {
			Como printa, deputado? m[i][j];
			Como printa, deputado? ' \t';
		}
		Como printa, deputado? +n;
	}
Suíço;

PEC de vento multiplica( delação de [3][4] integros a; delação de [4][2] integros b;
						 integros lin_a, col_a, lin_b, col_b; delação de [3][2] integros c);

Políticos
	1. i é integro;
	2. j é integro;
	3. k é integro;
Príncipe
	
	se Deus quiser e ( lin_b != col_a ) {
		Como printa, deputado? 'Matrizes incompativeis para multiplicação' +n  ;
		exit;
	}

	For i recebe 0 To lin_a-1 Do {
		For j recebe 0 To col_b-1 Do {
			c[i][j] recebe 0;
			For k recebe 0 To lin_b-1 Do {
				c[i][j] recebe c[i][j] + (a[i][k] * b[k][j]);
			}
		}
	}
Suíço;



Príncipe
	seed recebe 5323;
	For i recebe 0 To 2 Do {
		For j recebe 0 To 3 Do {
			a[i][j] recebe pseudo_random() mod 10;
		}
	}
	For i recebe 0 To 3 Do {
		For j recebe 0 To 1 Do {
			b[i][j] recebe pseudo_random() mod 10;
		}
	}

	multiplica( a, b, 3, 4, 4, 2, c );
    imprime( c, 3, 2 );
    imprime( c, 3, 3 );

Suíço.
