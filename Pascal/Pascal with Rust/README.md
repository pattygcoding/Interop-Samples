# Pascal with Rust

Free Pascal passes the numbers as command-line arguments to a compiled Rust
program and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Free Pascal |
| **Guest language** | Rust |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.pas`, `average_calculator.rs` |

## Prerequisites

- The **Free Pascal Compiler** (`fpc`)
- **rustc** 1.70 or newer

## Build & run

```bash
rustc -O average_calculator.rs -o average_calculator    # Windows: -o average_calculator.exe
fpc main.pas

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the Pascal program is `main.exe`, and `rustc` needs the `.exe` suffix
because it uses the `-o` name verbatim.

> **If FPC reports "Can't find unit Process".** The `process` unit lives in FPC's
> FCL directory, which some packaged installs — including the scoop build — leave
> out of the default search path. Point FPC at it explicitly:
>
> ```bash
> fpc -Fu"<fpc>/units/<target>/fcl-process" main.pas
> ```

You can also exercise the Rust side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./main
The average of 5 value(s) is: 30.00

$ ./main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Free Pascal has no pipe helper in the standard runtime, so the host uses the
`process` unit's `TProcess`:

```pascal
Helper.Executable := HelperExecutable;
for Index := 1 to Count do
  Helper.Parameters.Add(FormatFloat('0.######', Numbers[Index]));

Helper.Options := [poUsePipes];
Helper.Execute;

Captured.LoadFromStream(Helper.Output);
Helper.WaitOnExit;
```

Standard output is drained **before** waiting, so a full pipe buffer cannot
deadlock the child. `ExitStatus` is then checked before the value is trusted, and
a non-zero exit is turned into an exception that the main block reports.

`TryStrToFloat` with `DefaultFormatSettings.DecimalSeparator := '.'` makes both
parsing and `FormatFloat('0.00', ...)` independent of the machine's locale. The
helper's name is chosen with `{$IFDEF MSWINDOWS}`, because a shell only finds a
program in the current directory when the name says so — and Windows appends
`.exe` on its own.

`average_calculator.rs` parses each argument with `str::parse::<f64>()` and prints
`{:.2}`, rejecting anything unparsable with exit status 1.
