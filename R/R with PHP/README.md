# R with PHP

R passes the numbers as command-line arguments to a PHP program and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | R |
| **Guest language** | PHP |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.R`, `average_calculator.php` |

## Prerequisites

- **R** with `Rscript` on your `PATH`
- **PHP** 8.0 or newer (`php`) on your `PATH`

## Build & run

There is nothing to compile:

```bash
Rscript main.R                 # uses the built-in default data set
Rscript main.R 1 2 3 4
Rscript main.R -5 5 10
```

You can also exercise the PHP side on its own:

```bash
php average_calculator.php 10 20 30     # -> 20.00
```

## Expected output

```text
$ Rscript main.R
The average of 5 value(s) is: 30.00

$ Rscript main.R 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

R runs the helper with `system2`, asking it to capture stdout and stderr:

```r
output <- suppressWarnings(
  system2("php", c("average_calculator.php", as.character(numbers)),
          stdout = TRUE, stderr = TRUE)
)
```

When the command fails, `system2` records the exit status in a `"status"`
attribute, which the script checks before trusting the output — otherwise R would
happily try to parse the error text as a number.

`average_calculator.php` declares `strict_types=1`, vets every argument with
`is_numeric`, and prints `array_sum($numbers) / count($numbers)` with `%.2f`.
