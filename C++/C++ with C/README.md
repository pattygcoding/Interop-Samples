# C++ with C

C++ passes the numbers as command-line arguments to a compiled C program and reads
the average back through a pipe.

| | |
|---|---|
| **Host language** | C++17 |
| **Guest language** | C |
| **Bridge** | Child process + `popen` pipe |
| **Files** | `main.cpp`, `average_calculator.c` |

## Prerequisites

- A C and C++ compiler (`gcc`/`g++`, `clang`/`clang++`, or MSVC)

## Build & run

Two separate programs are built — the C helper is a standalone executable, not an
object file linked into the host:

```bash
gcc -O2 -Wall -Wextra average_calculator.c -o average_calculator
g++ -O2 -Wall -Wextra main.cpp -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows both programs gain the `.exe` suffix.

You can also exercise the C side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.cpp` renders the numbers into a command line and runs it with `popen`, which
hands C++ a pipe to the child's standard output. The executable name is
platform-dependent, because a shell only finds a program in the current directory
when the name says so:

```cpp
#ifdef _WIN32
constexpr const char *kExecutable = "average_calculator.exe";
#else
constexpr const char *kExecutable = "./average_calculator";
#endif
```

Arguments are formatted with `snprintf("%g")`, which keeps whole numbers short
(`10` rather than `10.000000`). `pclose` returns the child's exit status, so a
failure inside the helper is reported instead of being mistaken for a result.

`average_calculator.c` parses each argument with `strtod`, checking that the whole
token was consumed, and prints `total / count` with `%.2f`.
