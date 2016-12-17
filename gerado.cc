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
int tb_4;
int tb_5;
int tb_6;
int ti_7;
int ti_8;
int tb_9;
  v2[0] = 1.0;
  tb_4 = 0;
  ti_7 = 0;
l_inicio_for_1:;
  tb_5 = ti_7 >= 10;
  if( tb_5 ) goto l_fim_for_2;
  ti_8 = v1[ti_7];
  tb_6 = ti_8 == 5;
  if( tb_6 ) goto l_atrib_ss_3;
l_meio_for_4:;
  ti_7 = ti_7 + 1;
  goto l_inicio_for_1;
l_atrib_ss_3:;
    tb_4 = 1;
  goto l_meio_for_4;
l_fim_for_2:;
  cout << tb_4;
  cout << endl;
  cout << "a";
  cout << endl;
  tb_9 = 0;
  cout << tb_9;
  cout << endl;
  cout << "b";
  cout << endl;
  return 0;
}

