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
int v1[10];
double v2[10];
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
int ti_4;
int ti_5;
int tb_6;
int tb_7;
int tb_8;
int tb_9;
int tb_10;
int ti_11;
int ti_12;
int ti_13;
int tb_14;
int tb_15;
int tb_16;
int tb_17;
int tb_18;
int tb_19;
int tb_20;
int tb_21;
int ti_22;
int ti_23;
int tb_24;
  tb_6 = 10 >= 0;
  tb_7 = 10 < 10;
  tb_8 = 5 >= 0;
  tb_9 = 5 < 67;
  tb_10 = tb_6 && tb_7;
  tb_10 = tb_10 && tb_8;
  tb_10 = tb_10 && tb_9;
  if( tb_10 ) goto l_limite_array_ok_1;
  printf( "Limite de matriz ultrapassado. Deveria ter 0 <= %d <= %d e 0 <= %d <= %d ", 10, 9, 5, 66 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_1:;
ti_4 = 10 * 67;
ti_5 = ti_4 + 5;
matriz[ti_5] = 10;
  tb_14 = 10 >= 0;
  tb_15 = 10 < 10;
  tb_16 = 67 >= 0;
  tb_17 = 67 < 67;
  tb_18 = tb_14 && tb_15;
  tb_18 = tb_18 && tb_16;
  tb_18 = tb_18 && tb_17;
  if( tb_18 ) goto l_limite_array_ok_2;
  printf( "Limite de matriz ultrapassado. Deveria ter 0 <= %d <= %d e 0 <= %d <= %d ", 10, 9, 67, 66 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_2:;
ti_12 = 10 * 67;
ti_13 = ti_12 + 67;
ti_11 = matriz[ti_13];
  cout << ti_11;
  cout << endl;
  v2[0] = 1.0;
  tb_19 = 0;
  ti_22 = 0;
l_inicio_for_3:;
  tb_20 = ti_22 >= 10;
  if( tb_20 ) goto l_fim_for_4;
  ti_23 = v1[ti_22];
  tb_21 = ti_23 == 5;
  if( tb_21 ) goto l_atrib_ss_5;
l_meio_for_6:;
  ti_22 = ti_22 + 1;
  goto l_inicio_for_3;
l_atrib_ss_5:;
    tb_19 = 1;
  goto l_meio_for_6;
l_fim_for_4:;
  cout << tb_19;
  cout << endl;
  cout << "a";
  cout << endl;
  tb_24 = 0;
  cout << tb_24;
  cout << endl;
  cout << "b";
  cout << endl;
  return 0;
}

