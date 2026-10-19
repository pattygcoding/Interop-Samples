# Groovy with C

Groovy passes the numbers as command-line arguments to a compiled C program and
reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Groovy |
| **Guest language** | C |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.groovy`, `average_calculator.c` |

## Prerequisites

- **Groovy** 4 or newer with a JDK
- A C compiler (`gcc`, `clang`, or MSVC)

## Build & run

```bash
gcc -O2 -Wall -Wextra average_calculator.c -o average_calculator

groovy main.groovy                 # uses the built-in default data set
groovy main.groovy 1 2 3 4
groovy main.groovy -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.groovy` detects the
platform and looks for the right name.

You can also exercise the C side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ groovy main.groovy
The average of 5 value(s) is: 30.00

$ groovy main.groovy 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.groovy` starts the helper through `ProcessBuilder` with an argument vector
and drains both streams, so the helper's own diagnostics survive:

```groovy
def process = new ProcessBuilder([EXECUTABLE] + numbers.collect { it.toString() }).start()

def output = new StringBuilder()
def errors = new StringBuilder()
process.consumeProcessOutput(output, errors)
process.waitFor()
```

The printed value is checked against a numeric pattern before being parsed, so a
crash that prints a stack trace is reported rather than silently becoming zero,
and the exit code is examined first. The result is formatted with
`String.format(Locale.ROOT, ...)`, keeping the decimal separator independent of the
host locale.

`average_calculator.c` parses each argument with `strtod`, checking that the whole
token was consumed, and prints `total / count` with `%.2f`.
