#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

int a;
int b;
char str1[256];
char str2[256];
char vetor[2560];
int matriz[670];
int  soma(int a, int b ) {
int Result;
int c;
int d;
int ti_1;
int ti_2;
int ti_3;
  c = 3;
  d = 4;
  ti_1 = a + b;
  ti_2 = ti_1 + c;
  ti_3 = ti_2 + d;
  Result = ti_3;
  return Result;
}

int main() { 
char ts_4[256];
char ts_5[256];
int tb_6;
int tb_7;
int ti_8;
int tb_9;
int ti_10;
int tb_11;
  cout << 2;
  cout << endl;
  strncpy( str1, "como vota", 256 );
  strncpy( str2, "deputado?", 256 );
  strncpy( ts_4, str1, 256 );
  strncat( ts_4, " ", 256 );
  strncpy( ts_5, ts_4, 256 );
  strncat( ts_5, str2, 256 );
  cout << ts_5;
  cout << endl;
  a = 1;
l_inicio_while_3:;
  tb_6 = a <= 4;
tb_11 = !tb_6;
if ( tb_11 ) goto l_fim_while_4;
  cout << "a:";
  cout << endl;
  cout << a;
  cout << endl;
  b = 1;
l_inicio_while_1:;
  tb_7 = b <= 3;
tb_9 = !tb_7;
if ( tb_9 ) goto l_fim_while_2;
  cout << "b:";
  cout << endl;
  cout << b;
  cout << endl;
  ti_8 = b + 1;
  b = ti_8;
goto l_inicio_while_1;
l_fim_while_2:;
  ti_10 = a + 1;
  a = ti_10;
goto l_inicio_while_3;
l_fim_while_4:;
  return 0;
}

