Program HelloWorld;

Var
  b: Array [0 .. 2] [0 .. 4] Of Integer;

Begin
  b[2][4] := 3;
  WriteLn( b[2][4] );
End.	
