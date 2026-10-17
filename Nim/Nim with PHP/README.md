# Nim with PHP

Nim passes the numbers as command-line arguments to a PHP program and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | Nim |
| **Guest language** | PHP |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.nim`, `average_calculator.php` |

## Prerequisites

- The **Nim compiler** (`nim`) with a C backend (gcc or clang)
- **PHP** 8.0 or newer (`php`) on your `PATH`

## Build & run

```bash
nim c -d:release main.nim

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the program is `main.exe`.

You can also exercise the PHP side on its own:

```bash
php average_calculator.php 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./main
The average of 5 value(s) is: 30.00

$ ./main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.nim` runs the helper with `execCmdEx`, which returns both the captured
output and the exit status:

```nim
let outcome = execCmdEx(command)

if outcome.exitCode != 0:
  ...
```

`execCmdEx` merges stderr into the captured output by default, so a helper that
fails loudly produces a message rather than an empty string — and the exit code is
checked first, so the message is reported as an error instead of being parsed as a
result.

Every token is pre-validated by `isNumber` before `parseFloat` is called, and
values are formatted with `formatFloat(average, ffDecimal, 2)`, which always uses
a dot regardless of locale.

`average_calculator.php` declares `strict_types=1`, vets every argument with
`is_numeric`, and prints `array_sum($numbers) / count($numbers)` with `%.2f`.
