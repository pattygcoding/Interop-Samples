program Main;

{ Interop sample: Free Pascal driving a compiled Rust program.

  Free Pascal passes the numbers as command-line arguments to the Rust helper and
  reads the average it prints back from stdout.

  See README.md for build and run instructions. }

{$mode objfpc}{$H+}

uses
  Classes, Process, SysUtils;

const
  MaxNumbers = 64;

  DefaultNumbers: array[1..5] of Double = (10.0, 20.0, 30.0, 40.0, 50.0);

  { A shell only finds the helper in the current directory if the name says so,
    and Windows appends the .exe suffix on its own. }
  {$IFDEF MSWINDOWS}
  HelperExecutable = 'average_calculator.exe';
  {$ELSE}
  HelperExecutable = './average_calculator';
  {$ENDIF}

var
  Numbers: array[1..MaxNumbers] of Double;
  Count: Integer;
  Average: Double;

{ Convert command-line tokens to numbers, skipping anything invalid. }
procedure CollectNumbers;
var
  Index: Integer;
  Value: Double;
begin
  Count := 0;

  if ParamCount = 0 then
  begin
    for Index := Low(DefaultNumbers) to High(DefaultNumbers) do
    begin
      Inc(Count);
      Numbers[Count] := DefaultNumbers[Index];
    end;

    Exit;
  end;

  for Index := 1 to ParamCount do
    if TryStrToFloat(ParamStr(Index), Value) then
    begin
      Inc(Count);
      Numbers[Count] := Value;
    end
    else
      WriteLn(StdErr, 'warning: skipping non-numeric argument ''', ParamStr(Index), '''');
end;

{ Run the Rust helper and return the average it prints. }
function CalculateAverage: Double;
var
  Helper: TProcess;
  Captured: TStringList;
  Text: string;
  Index: Integer;
begin
  Helper := TProcess.Create(nil);
  Captured := TStringList.Create;
  try
    Helper.Executable := HelperExecutable;

    for Index := 1 to Count do
      Helper.Parameters.Add(FormatFloat('0.######', Numbers[Index]));

    Helper.Options := [poUsePipes];
    Helper.Execute;

    { Read everything before waiting, so a full pipe buffer cannot block. }
    Captured.LoadFromStream(Helper.Output);
    Helper.WaitOnExit;

    if Helper.ExitStatus <> 0 then
      raise Exception.Create('the Rust helper exited with code ' + IntToStr(Helper.ExitStatus));

    Text := Trim(Captured.Text);

    if not TryStrToFloat(Text, Result) then
      raise Exception.Create('unexpected output from the Rust helper: ' + Text);
  finally
    Captured.Free;
    Helper.Free;
  end;
end;

begin
  { Parse and print with a dot, whatever the machine's locale says. }
  DefaultFormatSettings.DecimalSeparator := '.';

  CollectNumbers;

  if Count = 0 then
  begin
    WriteLn(StdErr, 'error: no numbers to average');
    Halt(1);
  end;

  try
    Average := CalculateAverage;
    WriteLn('The average of ', Count, ' value(s) is: ', FormatFloat('0.00', Average));
  except
    on Error: Exception do
    begin
      WriteLn(StdErr, 'error: ', Error.Message);
      Halt(1);
    end;
  end;
end.
