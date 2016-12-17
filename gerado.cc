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
int ti_6;
int ti_7;
int ti_8;
int tb_9;
int tb_10;
int tb_11;
int ti_12;
int ti_13;
int tb_14;
ti_4 = 2 * 67;
ti_5 = ti_4 + 5;
matriz[ti_5] = 10;
ti_7 = 2 * 67;
ti_8 = ti_7 + 5;
ti_6 = matriz[ti_8];
  cout << ti_6;
  cout << endl;
  v2[0] = 1.0;
  tb_9 = 0;
  ti_12 = 0;
l_inicio_for_1:;
  tb_10 = ti_12 >= 10;
  if( tb_10 ) goto l_fim_for_2;
  ti_13 = v1[ti_12];
  tb_11 = ti_13 == 5;
  if( tb_11 ) goto l_atrib_ss_3;
l_meio_for_4:;
  ti_12 = ti_12 + 1;
  goto l_inicio_for_1;
l_atrib_ss_3:;
    tb_9 = 1;
  goto l_meio_for_4;
l_fim_for_2:;
  cout << tb_9;
  cout << endl;
  cout << "a";
  cout << endl;
  tb_14 = 0;
  cout << tb_14;
  cout << endl;
  cout << "b";
  cout << endl;
  return 0;
}

