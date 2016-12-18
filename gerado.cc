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
  d = 2;
  cout << "Função soma()";
  cout << endl;
  cout << a;
  cout << endl;
  cout << b;
  cout << endl;
  cout << c;
  cout << endl;
  cout << d;
  cout << endl;
  ti_1 = a + b;
  ti_2 = ti_1 + c;
  ti_3 = ti_2 + d;
  Result = ti_3;
  return Result;
}

int main() { 
int ti_4;
  a = 1;
  b = 1;
  cout << "Função main()";
  cout << endl;
  cout << a;
  cout << endl;
  cout << b;
  cout << endl;
  ti_4 = soma( 1, 2 );
  cout << ti_4;
  cout << endl;
  cout << "Função main()";
  cout << endl;
  cout << a;
  cout << endl;
  cout << b;
  cout << endl;
  return 0;
}

