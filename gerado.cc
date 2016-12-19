#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

int a;
double b;
int i;
char str1[256];
char str2[256];
int v1[5];
int v2[5];
int matriz[670];
void  soma(int c, int d ) {
int a;
  a = 1;
  cout << "Função soma()";
  cout << endl;
}

int main() { 
double td_1;
char ts_2[256];
char ts_3[256];
char ts_4[256];
char ts_5[256];
  a = 2;
  b = 2.5;
  soma( 1, 2 );
  td_1 = a + b;
  cout << td_1;
  cout << endl;
  sprintf( ts_3, "%d", a );
  strncpy( ts_2, ts_3, 256 );
  strncat( ts_2, "  ", 256 );
  sprintf( ts_5, "%lf", b );
  strncpy( ts_4, ts_2, 256 );
  strncat( ts_4, ts_5, 256 );
  cout << ts_4;
  cout << endl;
  return 0;
}

||||||| merged common ancestors
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
void  soma(int c, int d ) {
int a;
int b;
  a = 3;
  b = 4;
  cout << "Função soma()";
  cout << endl;
}

int main() { 
int tb_1;
int tb_2;
int tb_3;
  tb_1 = 4 >= 0;
  tb_2 = 4 <= 4;
  tb_3 = tb_1 && tb_2;
  if( tb_3 ) goto l_limite_array_ok_1;
  printf( "Limite de array ultrapassado: 0 <= %d <= %d", 4, 4 );
  cout << endl;
  exit( 1 );
  l_limite_array_ok_1:;
  v1[4] = 1;
  cout << a;
  cout << endl;
  return 0;
}
