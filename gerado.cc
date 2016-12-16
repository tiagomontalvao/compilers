#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

int  MDC(int a, int b, double teste ) {
int Result;
int ti_1;
int tb_2;
int ti_3;
int ti_4;
  ti_1 = a % b;
  tb_2 = ti_1 == 0;
  tb_2 = !tb_2;

  if( tb_2 ) goto l_else_1;
  Result = b;
  goto l_end_2;
l_else_1:;
  ti_3 = a % b;
  ti_4 = MDC( b, ti_3, 1.0 );
  Result = ti_4;
l_end_2:;
 return Result;
}

int main() { 
int ti_5;
  ti_5 = MDC( 48, 32, 1.0 );
  cout << ti_5;
  cout << endl;
}

