#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

int a;
char str1[256];
char str2[256];
char vetor[2560];
int matriz[670];

int main() { 
char ts_1[256];
int tb_2;
int tb_3;
int tb_4;
char ts_5[256];
char ts_6[256];
int tb_7;
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
  ts_1 = vetor[9];
  cout << ts_1;
  cout << endl;
  strncpy( ts_5, str1, 256 );
  strncat( ts_5, " ", 256 );
  strncpy( ts_6, ts_5, 256 );
  strncat( ts_6, str2, 256 );
  cout << ts_6;
  cout << endl;
  tb_7 = 3 < 3;
  cout << tb_7;
  cout << endl;
  return 0;
}

