#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

int a;
int b;
int  mdc(int a, int b ) {
int tb_1;
int ti_2;
int ti_3;
  tb_1 = b == 0;
  tb_1 = !tb_1;

  if( tb_1 ) goto l_else_1;
  return a;
  goto l_end_2;
l_else_1:;
  ti_2 = a % b;
  ti_3 = mdc( b, ti_2 );
  return ti_3;
l_end_2:;
}

int main() { 
char ts_4[256];
char ts_5[256];
char ts_6[256];
char ts_7[256];
char ts_8[256];
char ts_9[256];
int ti_10;
char ts_11[256];
char ts_12[256];
  cout << "Programa MDC";
  cout << endl;
  cout << "Digite o primeiro numero: ";
  cin >> a;
  cout << "Digite o segundo numero: ";
  cin >> b;
  sprintf( ts_5, "%d", a );
  strncpy( ts_4, "O MDC entre ", 256 );
  strncat( ts_4, ts_5, 256 );
  strncpy( ts_6, ts_4, 256 );
  strncat( ts_6, " e ", 256 );
  sprintf( ts_8, "%d", b );
  strncpy( ts_7, ts_6, 256 );
  strncat( ts_7, ts_8, 256 );
  strncpy( ts_9, ts_7, 256 );
  strncat( ts_9, " é ", 256 );
  ti_10 = mdc( a, b );
  sprintf( ts_12, "%d", ti_10 );
  strncpy( ts_11, ts_9, 256 );
  strncat( ts_11, ts_12, 256 );
  cout << ts_11;
  cout << endl;
  return 0;
}

