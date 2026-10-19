program AverageCalculator;

{ Interop sample: reads numbers from a text file and prints their arithmetic
  mean (two decimals) to standard output.

  Invoked by main.pl; see README.md for build and run instructions. }

{$mode objfpc}{$H+}

uses
  SysUtils;

var
  Input: Text;
  Path: string;
  Value, Total, Average: Double;
  Count: Integer;

begin
  if ParamCount < 1 then
  begin
    WriteLn(StdErr, 'usage: average <numbers-file>');
    Halt(1);
  end;

  Path := ParamStr(1);

  { Read every number in the file, regardless of line breaks. }
  DefaultFormatSettings.DecimalSeparator := '.';

  {$I-}
  Assign(Input, Path);
  Reset(Input);
  {$I+}
  if IOResult <> 0 then
  begin
    WriteLn(StdErr, 'error: cannot open ', Path);
    Halt(1);
  end;

  Total := 0.0;
  Count := 0;

  while not SeekEof(Input) do
  begin
    Read(Input, Value);
    Total := Total + Value;
    Inc(Count);
  end;

  Close(Input);

  if Count = 0 then
  begin
    WriteLn(StdErr, 'error: no numbers found in ', Path);
    Halt(1);
  end;

  Average := Total / Count;
  WriteLn(Average:0:2);
end.

