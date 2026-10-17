# V with R

V passes the numbers as command-line arguments to an R script and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | V |
| **Guest language** | R |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.v`, `average_calculator.R` |

## Prerequisites

- **V** 0.4 or newer, plus a C backend:
  - **Windows:** V ships TinyCC, so `v -cc tcc` works out of the box
  - **Linux / macOS:** the default `cc` (gcc or clang) is used
- **R** with `Rscript` on your `PATH`

## Build & run

```bash
v -cc tcc -o average main.v          # Linux/macOS: plain `v -o average main.v` also works

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the program is `average.exe`.

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

`main.v` runs the script through `os.execute`, which hands back both the exit code
and the captured output:

```v
result := os.execute(arguments.join(' '))

if result.exit_code != 0 {
    detail := result.output.trim_space()
    ...
}
```

`is_number` pre-validates every token because V's `str.f64()` quietly yields `0.0`
for unparsable input — without the check, `oops` would silently become a zero.
The average is printed with V's `${value:.2f}` interpolation.

On Windows, build with `-cc tcc`: the MinGW-w64 linker rejects an intrinsic in V's
runtime, while V's bundled TinyCC links it correctly.
