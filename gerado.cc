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
int vetor[10];
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
int tb_5;
int ti_6;
int tb_7;
int tb_8;
int tb_9;
int ti_10;
int tb_11;
int ti_12;
int tb_13;
int tb_14;
int tb_15;
int ti_16;
int ti_17;
int ti_18;
int tb_19;
  i = 0;
  ti_4 = 9;
l_teste_for_1:;
  tb_5 = i > ti_4;
  if( tb_5 ) goto l_fim_for_2;
  vetor[i] = i;
  i = i + 1;
  goto l_teste_for_1;
l_fim_for_2:;
  i = 0;
  ti_10 = 9;
l_teste_for_4:;
  tb_11 = i > ti_10;
  if( tb_11 ) goto l_fim_for_5;
  tb_7 = i >= 0;
  tb_8 = i <= 9;
  tb_9 = tb_7 && tb_8;
  if( tb_9 ) goto l_limite_array_ok_3;
  printf( "Limite de array ultrapassado: %d <= %d <= %d", 0 ,i, 9 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_3:;
  ti_6 = vetor[i];
  cout << ti_6;
  cout << endl;
  i = i + 1;
  goto l_teste_for_4;
l_fim_for_5:;
  cout << " ";
  cout << endl;
  ti_12 = 0 - 2;
  i = ti_12;
  ti_18 = 10;
l_teste_for_10:;
  tb_19 = i > ti_18;
  if( tb_19 ) goto l_fim_for_11;
  cout << i;
  cout << endl;
  tb_13 = 0;
  ti_16 = 0;
l_inicio_for_6:;
  tb_14 = ti_16 > 9;
  if( tb_14 ) goto l_fim_for_7;
  ti_17 = vetor[ti_16];
  tb_15 = ti_17 == i;
  if( tb_15 ) goto l_atrib_ss_8;
l_meio_for_9:;
  ti_16 = ti_16 + 1;
  goto l_inicio_for_6;
l_atrib_ss_8:;
    tb_13 = 1;
  goto l_meio_for_9;
l_fim_for_7:;
  cout << tb_13;
  cout << endl;
  i = i + 1;
  goto l_teste_for_10;
l_fim_for_11:;
  return 0;
}

