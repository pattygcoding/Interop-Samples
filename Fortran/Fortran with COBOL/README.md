# Fortran with COBOL

Fortran writes the numbers onto a compiled COBOL program's command line, runs it
with its output redirected to a file, and reads the average back.

| | |
|---|---|
| **Host language** | Fortran |
| **Guest language** | COBOL (GnuCOBOL) |
| **Bridge** | Child process + shell redirection |
| **Files** | `main.f90`, `average_calculator.cob` |
| **Platform** | **Linux** — the host invokes the helper as `./average_calculator` |

## Prerequisites

- **gfortran** (GNU Fortran)
- **GnuCOBOL** (`cobc`). On Debian/Ubuntu: `apt install gnucobol`.

## Build & run

```bash
cobc -x -o average_calculator average_calculator.cob
gfortran -O2 -o main main.f90

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

You can also exercise the COBOL side on its own:

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

Fortran 2008's `execute_command_line` runs the helper, with a shell redirect
carrying its output to a file:

```fortran
command = trim(command) // ' > ' // result_file
call execute_command_line(trim(command), wait=.true., exitstat=status)
```

`wait=.true.` makes the call block, and `exitstat` carries the helper's exit
status, so a failure inside COBOL is detected rather than silently producing a
bogus average. The result file is then read and closed with `status='delete'`, so
the sample leaves nothing behind.

`average_calculator.cob` collects its arguments with `ACCEPT ... FROM
ARGUMENT-NUMBER` / `FROM ARGUMENT-VALUE`, converts each with `FUNCTION NUMVAL`,
and prints the mean through a numeric-edited picture (`PIC Z(9)9.99`) so the
output is always two decimals wide.
