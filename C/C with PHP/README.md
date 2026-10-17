# C with PHP

C passes the numbers as command-line arguments to a PHP program and reads the
average back through a pipe.

| | |
|---|---|
| **Host language** | C |
| **Guest language** | PHP |
| **Bridge** | Child process + `popen` pipe |
| **Files** | `main.c`, `average_calculator.php` |

## Prerequisites

- A C compiler (`gcc`, `clang`, or MSVC)
- **PHP** 8.0 or newer (`php`) on your `PATH`

## Build & run

```bash
gcc -O2 -Wall -Wextra main.c -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the compiler writes `average.exe`, so run `.\average.exe` instead.

Run the program from this directory: it looks for `average_calculator.php` in the
working directory.

You can also exercise the PHP side on its own:

```bash
php average_calculator.php 10 20 30     # -> 20.00
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
FILE *pipe = popen("php average_calculator.php 10 20 30", "r");
```

`pclose` returns the child's exit status, so a failure inside PHP is reported
rather than silently producing a bogus average. The helper's own error messages
reach the terminal on stderr.

`average_calculator.php` declares `strict_types=1`, vets every argument with
`is_numeric`, and prints `array_sum($numbers) / count($numbers)` with `%.2f`.
