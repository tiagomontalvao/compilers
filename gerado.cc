#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

int a;
int b;
int i;
char str1[256];
char str2[256];
int v1[5];
int v2[5];
int matriz[670];
int  soma(int c, int d ) {
int Result;
int a;
int b;
int ti_1;
int ti_2;
int ti_3;
  a = 2;
  b = 2;
  c = 2;
  cout << "Função soma()";
  cout << a;
  cout << b;
  cout << c;
  cout << d;
  ti_1 = a + b;
  ti_2 = ti_1 + c;
  ti_3 = ti_2 + d;
  Result = ti_3;
  return Result;
}

int main() { 
char ts_4[256];
char ts_5[256];
char ts_6[256];
char ts_7[256];
int tb_8;
char ts_9[256];
char ts_10[256];
int tb_11;
char ts_12[256];
char ts_13[256];
int ti_14;
int tb_15;
int ti_16;
int tb_17;
int tb_18;
int ti_19;
  strncpy( str1, "como vota", 256 );
  strncpy( str2, "deputado?", 256 );
  strncpy( ts_4, "str1 + 2 + str2: ", 256 );
  strncat( ts_4, str1, 256 );
  sprintf( ts_6, "%d", 2 );
  strncpy( ts_5, ts_4, 256 );
  strncat( ts_5, ts_6, 256 );
  strncpy( ts_7, ts_5, 256 );
  strncat( ts_7, str2, 256 );
  cout << ts_7;
  cout << endl;
  a = 1;
l_inicio_while_3:;
  tb_8 = a <= 4;
tb_17 = !tb_8;
if ( tb_17 ) goto l_fim_while_4;
  sprintf( ts_10, "%d", a );
  strncpy( ts_9, "a: ", 256 );
  strncat( ts_9, ts_10, 256 );
  cout << ts_9;
  cout << endl;
  b = 1;
l_inicio_while_1:;
  tb_11 = b <= 3;
tb_15 = !tb_11;
if ( tb_15 ) goto l_fim_while_2;
  sprintf( ts_13, "%d", b );
  strncpy( ts_12, "b: ", 256 );
  strncat( ts_12, ts_13, 256 );
  cout << ts_12;
  cout << endl;
  ti_14 = b + 1;
  b = ti_14;
goto l_inicio_while_1;
l_fim_while_2:;
  ti_16 = a + 1;
  a = ti_16;
goto l_inicio_while_3;
l_fim_while_4:;
  a = 1;
  tb_18 = a < 2;
  tb_18 = !tb_18;

  if( tb_18 ) goto l_else_5;
  cout << a;
  cout << endl;
  goto l_end_6;
l_else_5:;
  ti_19 = 0 - a;
  cout << ti_19;
  cout << endl;
l_end_6:;
  return 0;
}

