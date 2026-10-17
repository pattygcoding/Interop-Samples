# C with Python

C passes the numbers as command-line arguments to a Python program and reads the
average back through a pipe.

| | |
|---|---|
| **Host language** | C |
| **Guest language** | Python 3 |
| **Bridge** | Child process + `popen` pipe |
| **Files** | `main.c`, `average_calculator.py` |

## Prerequisites

- A C compiler (`gcc`, `clang`, or MSVC)
- **Python 3.9+** on your `PATH`

## Build & run

```bash
gcc -O2 -Wall -Wextra main.c -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the compiler writes `average.exe`, so run `.\average.exe` instead.

Run the program from this directory: it looks for `average_calculator.py` in the
working directory.

If your interpreter is not called `python` (many Unix systems only provide
`python3`), set the `PYTHON` environment variable:

```bash
PYTHON=python3 ./average
```

You can also exercise the Python side on its own:

```bash
python average_calculator.py 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.c` renders the numbers into a command line and runs it with `popen`, which
hands C a pipe to the child's standard output:

```c
FILE *pipe = popen("python average_calculator.py 10 20 30", "r");
```

The interpreter name comes from the `PYTHON` environment variable when it is set,
which is what makes the sample work on systems where only `python3` exists.
`pclose` returns the child's exit status, so a failure inside Python is reported
rather than silently producing a bogus average.

`average_calculator.py` converts each argument with `float()`, reports the first
non-numeric one on stderr and exits with status 1, and prints the mean with
`f"{...:.2f}"`.
