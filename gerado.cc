#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

int v[2];

int main() { 
int tb_1;
int tb_2;
int tb_3;
int tb_4;
int tb_5;
int tb_6;
int ti_7;
int tb_8;
int tb_9;
int tb_10;
int tb_11;
  tb_1 = 0 >= 0;
  tb_2 = 0 <= 1;
  tb_3 = tb_1 && tb_2;
  if( tb_3 ) goto l_limite_array_ok_1;
  printf( "Limite de array ultrapassado: 0 <= %d <= %d", 0, 1 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_1:;
  v[0] = 10;
  tb_4 = 1 >= 0;
  tb_5 = 1 <= 1;
  tb_6 = tb_4 && tb_5;
  if( tb_6 ) goto l_limite_array_ok_2;
  printf( "Limite de array ultrapassado: 0 <= %d <= %d", 1, 1 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_2:;
  v[1] = 20;
  tb_8 = 0 >= 0;
  tb_9 = 0 <= 1;
  tb_10 = tb_8 && tb_9;
  if( tb_10 ) goto l_limite_array_ok_3;
  printf( "Limite de array ultrapassado: 0 <= %d <= %d", 0, 1 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_3:;
  ti_7 = v[0];
  tb_11 = ti_7 == 10;
  tb_11 = !tb_11;

  if( tb_11 ) goto l_else_4;
  cout << "IFZÃO, PORAR!";
  cout << endl;
  goto l_end_5;
l_else_4:;
  cout << "ELZÃO, AE!";
  cout << endl;
l_end_5:;
  return 0;
}

