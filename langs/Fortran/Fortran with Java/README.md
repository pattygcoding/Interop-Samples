# Fortran with Java

Fortran writes the numbers onto the Java helper's command line, runs it with its
output redirected to a file, and reads the average back.

| | |
|---|---|
| **Host language** | Fortran |
| **Guest language** | Java |
| **Bridge** | Child process + redirected output file |
| **Files** | `main.f90`, `AverageCalculator.java` |

## Prerequisites

- **gfortran** (part of GCC)
- A **JDK** 11 or newer, providing `javac` and `java`

## Build & run

```bash
javac AverageCalculator.java
gfortran -O2 -Wall -o average main.f90

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the program is `average.exe`. The class file must sit in the working
directory, because the helper is launched as `java AverageCalculator` with the
default classpath.

You can also exercise the Java side on its own:

```bash
java AverageCalculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Fortran has no pipe API, so the helper's output is redirected to a file and read
back afterwards:

```fortran
command = trim(command) // ' > ' // result_file
call execute_command_line(trim(command), wait=.true., exitstat=status)
```

Numbers are rendered with `write (buffer, '(F0.6)')`, and `parse_number` uses list
I/O with `iostat` to decide whether a token was numeric at all — the idiomatic
Fortran way to validate input, and the reason bad arguments are skipped with a
warning instead of aborting.

The result file is opened with `status='delete'`, so the temporary file disappears
as soon as it is closed. A non-zero `exitstat` is reported with the helper's
status, and the value itself is re-parsed from the file rather than trusted.

`AverageCalculator.java` parses each argument with `Double.parseDouble` and prints
through `System.out.printf(Locale.ROOT, "%.2f%n", ...)`, so the decimal separator
does not depend on the machine's default locale.
