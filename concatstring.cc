#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

char nomes[512];
char nome1[256];
char nome2[256];
char  formata(char a[256], char b[256] ) {
int tb_1;
int ti_2;
char ts_3[256];
char ts_4[256];
char ts_5[256];
char ts_6[256];
char ts_7[256];
char ts_8[256];
  ti_2 = strcmp( a, b );
  tb_1 = ti_2 > 0;
  tb_1 = !tb_1;

  if( tb_1 ) goto l_else_1;
  strncpy( ts_3, "Sr(a). ", 256 );
  strncat( ts_3, a, 256 );
  strncpy( ts_4, ts_3, 256 );
  strncat( ts_4, " ", 256 );
  strncpy( ts_5, ts_4, 256 );
  strncat( ts_5, b, 256 );
  return ts_5;
  goto l_end_2;
l_else_1:;
  strncpy( ts_6, "Mr(s). ", 256 );
  strncat( ts_6, b, 256 );
  strncpy( ts_7, ts_6, 256 );
  strncat( ts_7, " ", 256 );
  strncpy( ts_8, ts_7, 256 );
  strncat( ts_8, a, 256 );
  return ts_8;
l_end_2:;
}

int main() { 
char ts_9[256];
char ts_10[256];
char ts_11[256];
char ts_12[256];
char ts_13[256];
char ts_14[256];
char ts_15[256];
char ts_16[256];
  cout << "Digite o seu nome: ";
  cin >> nome1;
  cout << "Digite o seu sobrenome: ";
  cin >> nome2;
  cout << endl;
  ts_9 = formata( nome1, nome2 );
  strncpy( ts_10, "Bom dia, ", 256 );
  strncat( ts_10, ts_9, 256 );
  cout << ts_10;
  cout << endl;
  strncpy( ts_11, " ", 256 );
  strncat( ts_11, nome1, 256 );
  ts_12 = formata( ts_11, nome2 );
  strncpy( ts_13, "Bom dia, ", 256 );
  strncat( ts_13, ts_12, 256 );
  cout << ts_13;
  cout << endl;
  strncpy( ts_14, " ", 256 );
  strncat( ts_14, nome2, 256 );
  ts_15 = formata( nome1, ts_14 );
  strncpy( ts_16, "Bom dia, ", 256 );
  strncat( ts_16, ts_15, 256 );
  cout << ts_16;
  cout << endl;
  return 0;
}

