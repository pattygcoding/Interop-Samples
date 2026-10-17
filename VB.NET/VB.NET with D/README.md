# VB / VB.NET with D

VB.NET passes the numbers as command-line arguments to a compiled D program and
reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | VB.NET |
| **Guest language** | D |
| **Bridge** | Child process + argv/stdout |
| **Files** | `Program.vb`, `AverageCalculator.vbproj`, `average_calculator.d` |

## Prerequisites

- The **.NET SDK** 8.0 or newer
- The **DMD** compiler (`dmd`) — DMD ships from
  [dlang.org](https://dlang.org/download.html) and comes as part of the standard
  D toolchain

> **Windows runtime note.** DMD builds link against the Visual C++ 2013 runtime
> (`msvcr120.dll`). If the [VC++ 2013 redistributable](https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist)
> is not installed system-wide, add DMD's own `windows\bin64` folder — which
> contains a copy — to your `PATH`. Otherwise the helper exits with `0xC0000135`
> ("the specified module could not be found").

## Build & run

```bash
dmd -O average_calculator.d

dotnet run --project AverageCalculator.vbproj                 # default data set
dotnet run --project AverageCalculator.vbproj -- 1 2 3 4
dotnet run --project AverageCalculator.vbproj -- -5 5 10
```

DMD names the output after the source file, so the helper lands as
`average_calculator.exe` (`average_calculator` on Linux). Setting `-of=` here is
best avoided: DMD's Windows command line mangles that form.

You can also exercise the D side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ dotnet run --project AverageCalculator.vbproj
The average of 5 value(s) is: 30.00

$ dotnet run --project AverageCalculator.vbproj -- 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`Program.vb` starts the helper with `ProcessStartInfo` and passes each number
through `ArgumentList`, which quotes arguments for Windows correctly:

```vb
Dim startInfo As New ProcessStartInfo(HelperName) With {
    .RedirectStandardOutput = True,
    .RedirectStandardError = True,
    .UseShellExecute = False
}
startInfo.ArgumentList.Add(value.ToString(CultureInfo.InvariantCulture))
```

Both streams are read before `WaitForExit`, and numbers are rendered with
`CultureInfo.InvariantCulture` so a comma-decimal locale cannot corrupt the
protocol. The result is formatted with `ToString("F2", CultureInfo.InvariantCulture)`
for the same reason. `HelperName` gains `.exe` on Windows, where the D
toolchain's output name differs.

`average_calculator.d` converts each argument with `to!double`, catching
`ConvException` for anything unparsable, and prints `format("%.2f", ...)`.
