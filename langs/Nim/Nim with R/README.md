# Nim with R

Nim passes the numbers as command-line arguments to an R script and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | Nim |
| **Guest language** | R |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.nim`, `average_calculator.R` |

## Prerequisites

- **Nim** 1.6 or newer, with a C compiler it can use (`gcc` or `clang`)
- **R** with `Rscript` on your `PATH`

## Build & run

```bash
nim c -d:release --hints:off -o:average main.nim

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the compiler writes `average.exe`.

You can also exercise the R side on its own:

```bash
Rscript average_calculator.R 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Nim runs the script with `execCmdEx`, which returns the output and the exit code
together:

```nim
let outcome = execCmdEx(command)

if outcome.exitCode != 0:
  raise newException(IOError, ...)
```

`execCmdEx` merges stderr into its output by default, so an R error message
reaches the Nim side rather than disappearing.

`isNumber` pre-validates each token before `parseFloat` is called, because Nim's
`parseFloat` raises on bad input and the sample would rather warn and skip.
`average_calculator.R` converts its arguments with `as.numeric` and prints
`mean(numbers)` through `sprintf("%.2f")`.
