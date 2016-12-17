#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

int a;
char str1[256];
char str2[256];
int vetor[10];

int main() { 
int ti_1;
int tb_2;
int tb_3;
int tb_4;
int ti_5;
char ts_6[256];
char ts_7[256];
int tb_8;
  vetor[9] = 6;
  strncpy( str1, "como vota", 256 );
  strncpy( str2, "deputado?", 256 );
  tb_2 = 9 >= 0;
  tb_3 = 9 <= 9;
  tb_4 = tb_2 && tb_3;
  if( tb_4 ) goto l_limite_array_ok_1;
    printf( "Limite de array ultrapassado: %d <= %d <= %d", 0 ,9, 9 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_1:;
  ti_1 = vetor[9];
  ti_5 = ti_1 + 1;
  cout << ti_5;
  cout << endl;
  strncpy( ts_6, str1, 256 );
  strncat( ts_6, " ", 256 );
  strncpy( ts_7, ts_6, 256 );
  strncat( ts_7, str2, 256 );
  cout << ts_7;
  cout << endl;
  tb_8 = 3 < 3;
  cout << tb_8;
  cout << endl;
  return 0;
}

