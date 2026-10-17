program AverageCalculator;

{ Interop sample: prints the arithmetic mean of the numbers given on the command
  line.

  Invoked by main.sh; see README.md for build and run instructions. }

{$mode objfpc}{$H+}

uses
  SysUtils;

var
  Total, Value, Average: Double;
  Count, Index: Integer;

begin
  { Parse and print with a dot, whatever the machine's locale says. }
  DefaultFormatSettings.DecimalSeparator := '.';

  if ParamCount = 0 then
  begin
    WriteLn(StdErr, 'error: no numbers supplied');
    Halt(1);
  end;

  Total := 0.0;
  Count := 0;

  for Index := 1 to ParamCount do
  begin
    if not TryStrToFloat(ParamStr(Index), Value) then
    begin
      WriteLn(StdErr, 'error: ''', ParamStr(Index), ''' is not a number');
      Halt(1);
    end;

    Total := Total + Value;
    Inc(Count);
  end;

  Average := Total / Count;
  WriteLn(FormatFloat('0.00', Average));
end.
