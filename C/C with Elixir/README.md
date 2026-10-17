# C with Elixir

C passes the numbers as command-line arguments to an Elixir script and reads the
average back through a pipe.

| | |
|---|---|
| **Host language** | C |
| **Guest language** | Elixir |
| **Bridge** | Child process + `popen` pipe |
| **Files** | `main.c`, `average_calculator.exs` |

## Prerequisites

- A C compiler (`gcc`, `clang`, or MSVC)
- **Elixir** 1.12 or newer, with a working Erlang/OTP installation, on your `PATH`

## Build & run

```bash
gcc -O2 -Wall -Wextra main.c -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the compiler writes `average.exe`, so run `.\average.exe` instead.

Run the program from this directory: it looks for `average_calculator.exs` in the
working directory.

You can also exercise the Elixir side on its own:

```bash
elixir average_calculator.exs 10 20 30     # -> 20.00
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
gives C a pipe to the child's standard output:

```c
FILE *pipe = popen("elixir average_calculator.exs 10 20 30", "r");
```

It then reads the single line Elixir prints and re-parses it with `strtod`.
`pclose` returns the child's exit status, so a failure inside Elixir is reported
rather than silently producing a bogus average.

`average_calculator.exs` parses `System.argv/0` with `Integer.parse/1`, rejects
anything that is not an integer, and prints the mean via `:io.format/2` using
`~.2f`.
