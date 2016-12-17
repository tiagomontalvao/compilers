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
int tb_1;
int ti_2;
int tb_3;
int ti_4;
int tb_5;
int ti_6;
int tb_7;
int ti_8;
int tb_9;
int ti_10;
int tb_11;
int ti_12;
  strncpy( str1, "como vota", 256 );
  strncpy( str2, "deputado?", 256 );
  ti_2 = strcmp( str1, str2 );
  tb_1 = ti_2 < 0;
  cout << tb_1;
  cout << endl;
  ti_4 = strcmp( str1, str2 );
  tb_3 = ti_4 <= 0;
  cout << tb_3;
  cout << endl;
  ti_6 = strcmp( str1, str2 );
  tb_5 = ti_6 > 0;
  cout << tb_5;
  cout << endl;
  ti_8 = strcmp( str1, str2 );
  tb_7 = ti_8 >= 0;
  cout << tb_7;
  cout << endl;
  ti_10 = strcmp( str1, str2 );
  tb_9 = ti_10 == 0;
  cout << tb_9;
  cout << endl;
  ti_12 = strcmp( str1, str2 );
  tb_11 = ti_12 != 0;
  cout << tb_11;
  cout << endl;
  return 0;
}

