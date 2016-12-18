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
int a;
int b;
int ti_1;
int ti_2;
int ti_3;
  a = 3;
  b = 4;
  cout << "Função soma()";
  cout << endl;
  ti_1 = a + b;
  ti_2 = ti_1 + c;
  ti_3 = ti_2 + d;
  return ti_3;
}

int main() { 
int ti_4;
  ti_4 = soma( 1, 2 );
  cout << ti_4;
  cout << endl;
  strncpy( str1, "como vota", 256 );
  strncpy( str2, "deputado?", 256 );
  return 0;
}

