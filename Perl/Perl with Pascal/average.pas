program AverageCalculator;
var
   i: integer;
   sum, average: real;
   numbers: array[1..5] of real;
   inputFile: Text;
   numString: string;
   numValue: real;
begin
   assign(inputFile, 'numbers.txt');
   reset(inputFile);
   readln(inputFile, numString);
   close(inputFile);

   sum := 0.0;

   i := 1;
   while numString <> '' do
   begin
      val(copy(numString, 1, pos(' ', numString) - 1), numValue);
      numbers[i] := numValue;
      sum := sum + numbers[i];
      delete(numString, 1, pos(' ', numString));
      i := i + 1;
   end;

   average := sum / (i - 1);

   writeln(average:0:2);
end.
